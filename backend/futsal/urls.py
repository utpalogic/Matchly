from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import *

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'futsals', FutsalViewSet, basename='futsal')
router.register(r'grounds', GroundViewSet, basename='ground')
router.register(r'timeslots', TimeSlotViewSet, basename='timeslot')
router.register(r'teams', TeamViewSet, basename='team')
router.register(r'bookings', BookingViewSet, basename='booking')
router.register(r'tournaments', TournamentViewSet, basename='tournament')
router.register(r'fixtures', FixtureViewSet, basename='fixture')
router.register(r'posts', PostViewSet, basename='post')
router.register(r'comments', CommentViewSet, basename='comment')

urlpatterns = [
    path('', include(router.urls)),
    path('register/', register, name='register'),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]