from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import *

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 
            'username', 
            'email', 
            'phone', 
            'full_name',  
            'gender',  
            'date_of_birth', 
            'preferred_position', 
            'matches_played', 
            'is_looking_for_team',
            'is_blocked',
            'role',
            'futsal'
        ]
        read_only_fields = ['id', 'matches_played', 'is_blocked', 'role']

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    confirm_password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = [
            'username', 
            'email', 
            'password', 
            'confirm_password',
            'phone', 
            'full_name',  
            'gender',  
            'date_of_birth', 
            'preferred_position'
        ]
    
    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords don't match")
        return data
    
    def create(self, validated_data):
        validated_data.pop('confirm_password')
        user = User.objects.create_user(**validated_data)
        return user

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'phone', 'preferred_position']
    
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class GroundSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ground
        fields = '__all__'

class TimeSlotSerializer(serializers.ModelSerializer):
    ground_name = serializers.CharField(source='ground.name', read_only=True)
    
    class Meta:
        model = TimeSlot
        fields = ['id', 'ground', 'ground_name', 'date', 'start_time', 'end_time', 'is_booked']

class FutsalSerializer(serializers.ModelSerializer):
    grounds = GroundSerializer(many=True, read_only=True)
    
    class Meta:
        model = Futsal
        fields = '__all__'

class TeamSerializer(serializers.ModelSerializer):
    captain_name = serializers.CharField(source='captain.username', read_only=True)
    members_count = serializers.SerializerMethodField()
    reward_progress = serializers.SerializerMethodField()
    
    class Meta:
        model = Team
        fields = ['id', 'name', 'captain', 'captain_name', 'members', 'matches_count', 
                  'members_count', 'reward_progress', 'created_at']
    
    def get_members_count(self, obj):
        return obj.members.count()
    
    def get_reward_progress(self, obj):
        try:
            tracker = obj.reward_tracker
            return {
                'current': tracker.matches_since_reward,
                'target': 8,
                'eligible': tracker.is_eligible_for_reward(),
                'total_claimed': tracker.total_rewards_claimed
            }
        except RewardTracker.DoesNotExist:
            return {'current': 0, 'target': 8, 'eligible': False, 'total_claimed': 0}

class BookingSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.username', read_only=True)
    ground_name = serializers.CharField(source='ground.name', read_only=True)
    futsal_name = serializers.CharField(source='ground.futsal.name', read_only=True)
    time_slot_detail = TimeSlotSerializer(source='time_slot', read_only=True)
    
    class Meta:
        model = Booking
        fields = ['id', 'user', 'user_name', 'team', 'ground', 'ground_name', 
                  'futsal_name', 'time_slot', 'time_slot_detail', 'status', 
                  'payment_status', 'amount_paid', 'is_reward_booking', 
                  'booking_date', 'notes']
        read_only_fields = ['id', 'booking_date']
    
    def create(self, validated_data):
        booking = Booking.objects.create(**validated_data)
        # Marking time slot as booked
        time_slot = booking.time_slot
        time_slot.is_booked = True
        time_slot.save()
        return booking

class TournamentSerializer(serializers.ModelSerializer):
    registered_teams_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Tournament
        fields = '__all__'
    
    def get_registered_teams_count(self, obj):
        return obj.registered_teams.count()

class FixtureSerializer(serializers.ModelSerializer):
    team1_name = serializers.CharField(source='team1.name', read_only=True)
    team2_name = serializers.CharField(source='team2.name', read_only=True)
    ground_name = serializers.CharField(source='ground.name', read_only=True)
    tournament_name = serializers.CharField(source='tournament.name', read_only=True)
    
    class Meta:
        model = Fixture
        fields = '__all__'

class CommentSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.username', read_only=True)
    author_picture = serializers.ImageField(source='author.profile_picture', read_only=True)
    
    class Meta:
        model = Comment
        fields = ['id', 'post', 'author', 'author_name', 'author_picture', 'content', 'created_at']
        read_only_fields = ['id', 'author', 'created_at']

class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.username', read_only=True)
    author_picture = serializers.ImageField(source='author.profile_picture', read_only=True)
    likes_count = serializers.SerializerMethodField()
    comments_count = serializers.SerializerMethodField()
    comments = CommentSerializer(many=True, read_only=True)
    is_liked = serializers.SerializerMethodField()
    
    class Meta:
        model = Post
        fields = ['id', 'author', 'author_name', 'author_picture', 'post_type', 
                  'title', 'content', 'image', 'likes_count', 'comments_count', 
                  'comments', 'is_liked', 'created_at', 'updated_at']
        read_only_fields = ['id', 'author', 'created_at', 'updated_at']
    
    def get_likes_count(self, obj):
        return obj.total_likes()
    
    def get_comments_count(self, obj):
        return obj.comments.count()
    
    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.likes.filter(id=request.user.id).exists()
        return False