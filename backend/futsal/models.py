from django.db import models

# Create models here.
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import timezone

# Custom User Model
class User(AbstractUser):
    ROLE_CHOICES = [
        ('USER', 'Regular User'),
        ('OWNER', 'Futsal Owner'),
        ('ADMIN', 'Super Admin'),
    ]
    
    GENDER_CHOICES = [
        ('MALE', 'Male'),
        ('FEMALE', 'Female'),
        ('OTHER', 'Other'),
    ]
    
    POSITION_CHOICES = [
        ('GK', 'Goalkeeper'),
        ('DEF', 'Defender'),
        ('MID', 'Midfielder'),
        ('FWD', 'Forward'),
    ]
    
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='USER')
    phone = models.CharField(max_length=15, blank=True, null=True)
    preferred_position = models.CharField(max_length=3, choices=POSITION_CHOICES, blank=True, null=True)
    matches_played = models.IntegerField(default=0)
    is_looking_for_team = models.BooleanField(default=False)
    is_blocked = models.BooleanField(default=False)
    futsal = models.ForeignKey('Futsal', on_delete=models.SET_NULL, null=True, blank=True)
    

    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, blank=True, null=True)
    full_name = models.CharField(max_length=255, blank=True, null=True)
    

    password_reset_token = models.CharField(max_length=100, blank=True, null=True)
    password_reset_token_created = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return self.username


# Futsal Venue
class Futsal(models.Model):
    name = models.CharField(max_length=200)
    location = models.CharField(max_length=300)
    description = models.TextField(blank=True)
    contact = models.CharField(max_length=15)
    image = models.ImageField(upload_to='futsals/', null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


# Ground within Futsal
class Ground(models.Model):
    futsal = models.ForeignKey(Futsal, on_delete=models.CASCADE, related_name='grounds')
    name = models.CharField(max_length=50)  # e.g., "Ground A", "Ground B"
    price_per_hour = models.DecimalField(max_digits=10, decimal_places=2)
    is_available = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.futsal.name} - {self.name}"


# Time Slot
class TimeSlot(models.Model):
    ground = models.ForeignKey(Ground, on_delete=models.CASCADE, related_name='time_slots')
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_booked = models.BooleanField(default=False)

    class Meta:
        unique_together = ('ground', 'date', 'start_time')

    def __str__(self):
        return f"{self.ground} - {self.date} {self.start_time}-{self.end_time}"


# Team
class Team(models.Model):
    name = models.CharField(max_length=100)
    captain = models.ForeignKey(User, on_delete=models.CASCADE, related_name='captained_teams')
    members = models.ManyToManyField(User, related_name='teams', blank=True)
    matches_count = models.IntegerField(default=0)  # For reward tracking
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


# Booking
class Booking(models.Model):
    STATUS_CHOICES = [
        ('CONFIRMED', 'Confirmed'),
        ('WAITLISTED', 'Waitlisted'),
        ('CANCELLED', 'Cancelled'),
        ('COMPLETED', 'Completed'),
    ]
    
    PAYMENT_STATUS = [
        ('PAID', 'Paid'),
        ('PENDING', 'Pending'),
        ('DOWN_PAYMENT', 'Down Payment'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    team = models.ForeignKey(Team, on_delete=models.SET_NULL, null=True, blank=True, related_name='bookings')
    ground = models.ForeignKey(Ground, on_delete=models.CASCADE)
    time_slot = models.ForeignKey(TimeSlot, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='CONFIRMED')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='PENDING')
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    is_reward_booking = models.BooleanField(default=False)  # Free 8th match
    booking_date = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.ground} - {self.time_slot.date}"


# Tournament
class Tournament(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    start_date = models.DateField()
    end_date = models.DateField()
    prize = models.CharField(max_length=200, blank=True)
    registration_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    max_teams = models.IntegerField(default=16)
    registered_teams = models.ManyToManyField(Team, related_name='tournaments', blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


# Match Fixture
class Fixture(models.Model):
    tournament = models.ForeignKey(Tournament, on_delete=models.CASCADE, related_name='fixtures')
    team1 = models.ForeignKey(Team, on_delete=models.CASCADE, related_name='fixtures_as_team1')
    team2 = models.ForeignKey(Team, on_delete=models.CASCADE, related_name='fixtures_as_team2')
    ground = models.ForeignKey(Ground, on_delete=models.SET_NULL, null=True)
    match_date = models.DateField()
    match_time = models.TimeField()
    team1_score = models.IntegerField(null=True, blank=True)
    team2_score = models.IntegerField(null=True, blank=True)
    winner = models.ForeignKey(Team, on_delete=models.SET_NULL, null=True, blank=True, related_name='won_fixtures')
    is_completed = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.tournament.name}: {self.team1.name} vs {self.team2.name}"


# Community Post
class Post(models.Model):
    POST_TYPE = [
        ('HIGHLIGHT', 'Match Highlight'),
        ('ANNOUNCEMENT', 'Announcement'),
        ('LOOKING', 'Looking for Match'),
        ('GENERAL', 'General'),
    ]

    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    post_type = models.CharField(max_length=20, choices=POST_TYPE, default='GENERAL')
    title = models.CharField(max_length=200)
    content = models.TextField()
    image = models.ImageField(upload_to='posts/', null=True, blank=True)
    likes = models.ManyToManyField(User, related_name='liked_posts', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title

    def total_likes(self):
        return self.likes.count()


# Comment on Post
class Comment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comments')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Comment by {self.author.username} on {self.post.title}"


# Reward Tracking
class RewardTracker(models.Model):
    team = models.OneToOneField(Team, on_delete=models.CASCADE, related_name='reward_tracker')
    matches_since_reward = models.IntegerField(default=0)
    total_rewards_claimed = models.IntegerField(default=0)
    next_reward_at = models.IntegerField(default=8)

    def __str__(self):
        return f"{self.team.name} - {self.matches_since_reward}/8 matches"

    def is_eligible_for_reward(self):
        return self.matches_since_reward >= 8