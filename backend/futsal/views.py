from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from django.contrib.auth import get_user_model
from django.db.models import Q
from .models import *
from .serializers import *

User = get_user_model()

# User Registration & Profile
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    
    def get_permissions(self):
        if self.action == 'create':
            return [AllowAny()]
        return [IsAuthenticated()]
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
    
    @action(detail=False, methods=['patch'])
    def update_profile(self, request):
        serializer = self.get_serializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def toggle_looking_for_team(self, request):
        user = request.user
        user.is_looking_for_team = not user.is_looking_for_team
        user.save()
        return Response({'is_looking_for_team': user.is_looking_for_team})
    
    @action(detail=False, methods=['get'])
    def looking_for_team(self, request):
        users = User.objects.filter(is_looking_for_team=True).exclude(id=request.user.id)
        serializer = self.get_serializer(users, many=True)
        return Response(serializer.data)

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response({
            'message': 'User created successfully',
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Futsal & Grounds
class FutsalViewSet(viewsets.ModelViewSet):
    queryset = Futsal.objects.filter(is_active=True)
    serializer_class = FutsalSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'location']
    
    @action(detail=True, methods=['get'])
    def available_slots(self, request, pk=None):
        futsal = self.get_object()
        date = request.query_params.get('date')
        
        if not date:
            return Response({'error': 'Date parameter required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        slots = TimeSlot.objects.filter(
            ground__futsal=futsal,
            date=date,
            is_booked=False
        )
        serializer = TimeSlotSerializer(slots, many=True)
        return Response(serializer.data)

class GroundViewSet(viewsets.ModelViewSet):
    queryset = Ground.objects.all()
    serializer_class = GroundSerializer
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        return [IsAdminUser()]

# Time Slots
class TimeSlotViewSet(viewsets.ModelViewSet):
    queryset = TimeSlot.objects.all()
    serializer_class = TimeSlotSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        queryset = TimeSlot.objects.all()
        ground_id = self.request.query_params.get('ground')
        date = self.request.query_params.get('date')
        available_only = self.request.query_params.get('available')
        
        if ground_id:
            queryset = queryset.filter(ground_id=ground_id)
        if date:
            queryset = queryset.filter(date=date)
        if available_only:
            queryset = queryset.filter(is_booked=False)
        
        return queryset.order_by('date', 'start_time')

# Teams
class TeamViewSet(viewsets.ModelViewSet):
    queryset = Team.objects.all()
    serializer_class = TeamSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        team = serializer.save(captain=self.request.user)
        # Create reward tracker
        RewardTracker.objects.create(team=team)
    
    @action(detail=True, methods=['post'])
    def join(self, request, pk=None):
        team = self.get_object()
        team.members.add(request.user)
        return Response({'message': 'Joined team successfully'})
    
    @action(detail=True, methods=['post'])
    def leave(self, request, pk=None):
        team = self.get_object()
        if team.captain == request.user:
            return Response({'error': 'Captain cannot leave team'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        team.members.remove(request.user)
        return Response({'message': 'Left team successfully'})
    
    @action(detail=False, methods=['get'])
    def my_teams(self, request):
        teams = Team.objects.filter(
            Q(captain=request.user) | Q(members=request.user)
        ).distinct()
        serializer = self.get_serializer(teams, many=True)
        return Response(serializer.data)

# Bookings
class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return Booking.objects.all()
        return Booking.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        booking = serializer.save(user=self.request.user)
        
        # Update team matches count for reward tracking
        if booking.team:
            booking.team.matches_count += 1
            booking.team.save()
            
            try:
                tracker = booking.team.reward_tracker
                tracker.matches_since_reward += 1
                
                if tracker.is_eligible_for_reward():
                    tracker.matches_since_reward = 0
                    tracker.total_rewards_claimed += 1
                
                tracker.save()
            except RewardTracker.DoesNotExist:
                RewardTracker.objects.create(team=booking.team, matches_since_reward=1)
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        booking = self.get_object()
        if booking.user != request.user and not request.user.is_staff:
            return Response({'error': 'Not authorized'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        booking.status = 'CANCELLED'
        booking.save()
        
        # Free up the time slot
        time_slot = booking.time_slot
        time_slot.is_booked = False
        time_slot.save()
        
        return Response({'message': 'Booking cancelled'})
    
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        booking = self.get_object()
        if not request.user.is_staff:
            return Response({'error': 'Admin only'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        booking.status = 'COMPLETED'
        booking.save()
        
        # Increment matches played for user
        booking.user.matches_played += 1
        booking.user.save()
        
        return Response({'message': 'Booking marked as completed'})

# Tournaments
class TournamentViewSet(viewsets.ModelViewSet):
    queryset = Tournament.objects.all()
    serializer_class = TournamentSerializer
    permission_classes = [IsAuthenticated]
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        return [IsAdminUser()]
    
    @action(detail=True, methods=['post'])
    def register_team(self, request, pk=None):
        tournament = self.get_object()
        team_id = request.data.get('team_id')
        
        try:
            team = Team.objects.get(id=team_id)
            if team.captain != request.user:
                return Response({'error': 'Only captain can register team'}, 
                              status=status.HTTP_403_FORBIDDEN)
            
            if tournament.registered_teams.count() >= tournament.max_teams:
                return Response({'error': 'Tournament is full'}, 
                              status=status.HTTP_400_BAD_REQUEST)
            
            tournament.registered_teams.add(team)
            return Response({'message': 'Team registered successfully'})
        except Team.DoesNotExist:
            return Response({'error': 'Team not found'}, 
                          status=status.HTTP_404_NOT_FOUND)

# Fixtures
class FixtureViewSet(viewsets.ModelViewSet):
    queryset = Fixture.objects.all()
    serializer_class = FixtureSerializer
    permission_classes = [IsAuthenticated]
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        return [IsAdminUser()]
    
    def get_queryset(self):
        queryset = Fixture.objects.all()
        tournament_id = self.request.query_params.get('tournament')
        if tournament_id:
            queryset = queryset.filter(tournament_id=tournament_id)
        return queryset.order_by('match_date', 'match_time')

# Community Posts
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['title', 'content']
    
    def get_serializer_context(self):
        return {'request': self.request}
    
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
    
    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        post = self.get_object()
        if post.likes.filter(id=request.user.id).exists():
            post.likes.remove(request.user)
            return Response({'message': 'Unliked', 'likes_count': post.total_likes()})
        else:
            post.likes.add(request.user)
            return Response({'message': 'Liked', 'likes_count': post.total_likes()})
    
    @action(detail=True, methods=['post'])
    def add_comment(self, request, pk=None):
        post = self.get_object()
        content = request.data.get('content')
        
        if not content:
            return Response({'error': 'Content required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        comment = Comment.objects.create(
            post=post,
            author=request.user,
            content=content
        )
        serializer = CommentSerializer(comment)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

# Comments
class CommentViewSet(viewsets.ModelViewSet):
    queryset = Comment.objects.all()
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)