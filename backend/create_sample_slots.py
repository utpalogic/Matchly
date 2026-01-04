import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'futsal_project.settings')
django.setup()

from futsal.models import Ground, TimeSlot
from datetime import date, time, timedelta

print("Starting time slot creation...")
grounds = Ground.objects.all()
print(f"Found {grounds.count()} grounds")

if not grounds.exists():
    print("Error: No grounds found! Please create grounds first.")
    exit()
today = date.today()
slots_created = 0

for ground in grounds:
    print(f"\nCreating slots for: {ground.name}")
    ground_slots = 0
    # Create slots for next 150 days
    for day in range(150):
        slot_date = today + timedelta(days=day)
        
        # Morning slots: 6 AM - 12 PM
        for hour in range(6, 12):
            TimeSlot.objects.create(
                ground=ground,
                date=slot_date,
                start_time=time(hour, 0),
                end_time=time(hour + 1, 0),
                is_booked=False
            )
            slots_created += 1
            ground_slots += 1
        
        # Afternoon slots: 1 PM - 5 PM
        for hour in range(13, 17):
            TimeSlot.objects.create(
                ground=ground,
                date=slot_date,
                start_time=time(hour, 0),
                end_time=time(hour + 1, 0),
                is_booked=False
            )
            slots_created += 1
            ground_slots += 1
        
        # Evening slots: 6 PM - 10 PM
        for hour in range(18, 22):
            TimeSlot.objects.create(
                ground=ground,
                date=slot_date,
                start_time=time(hour, 0),
                end_time=time(hour + 1, 0),
                is_booked=False
            )
            slots_created += 1
            ground_slots += 1
    
    print(f"  Created {ground_slots} slots for {ground.name}")

print(f"\nTotal slots created: {slots_created}")
print("Done!")