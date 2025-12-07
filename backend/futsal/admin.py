from django.contrib import admin

# Register models here.
from django.contrib import admin
from .models import *

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
