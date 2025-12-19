from django.contrib import admin
from .models import User, Futsal, Ground, TimeSlot, Booking, Team, Tournament, Fixture, Post, Comment, RewardTracker

admin.site.register(User)
admin.site.register(Futsal)
admin.site.register(Ground)
admin.site.register(TimeSlot)
admin.site.register(Booking)
admin.site.register(Team)
admin.site.register(Tournament)
admin.site.register(Fixture)
admin.site.register(Post)
admin.site.register(Comment)
admin.site.register(RewardTracker)