from django.core.management.base import BaseCommand
from futsal.models import Ground, TimeSlot
from datetime import datetime, timedelta, time

class Command(BaseCommand):
    help = 'Create time slots for all grounds'

    def handle(self, *args, **kwargs):
        grounds = Ground.objects.all()
        
        if not grounds.exists():
            self.stdout.write(self.style.ERROR('No grounds found! Please create grounds first.'))
            return
        
        # Time slots from 6 AM to 9 PM (every hour)
        time_slots = [
            (time(6, 0), time(7, 0)),
            (time(7, 0), time(8, 0)),
            (time(8, 0), time(9, 0)),
            (time(9, 0), time(10, 0)),
            (time(10, 0), time(11, 0)),
            (time(11, 0), time(12, 0)),
            (time(12, 0), time(13, 0)),
            (time(13, 0), time(14, 0)),
            (time(14, 0), time(15, 0)),
            (time(15, 0), time(16, 0)),
            (time(16, 0), time(17, 0)),
            (time(17, 0), time(18, 0)),
            (time(18, 0), time(19, 0)),
            (time(19, 0), time(20, 0)),
            (time(20, 0), time(21, 0)),
        ]
        
        created_count = 0
        
        for ground in grounds:
            self.stdout.write(f'Creating time slots for {ground.name} at {ground.futsal.name}...')
            
            # Create time slots for next 14 days
            for day in range(14):
                date = datetime.now().date() + timedelta(days=day)
                
                for start_time, end_time in time_slots:
                    slot, created = TimeSlot.objects.get_or_create(
                        ground=ground,
                        date=date,
                        start_time=start_time,
                        defaults={'end_time': end_time}
                    )
                    if created:
                        created_count += 1
        
        self.stdout.write(self.style.SUCCESS(f'Successfully created {created_count} time slots!'))
        self.stdout.write(self.style.SUCCESS(f'Time slots created for next 14 days'))
        self.stdout.write(self.style.SUCCESS(f'Grounds covered: {grounds.count()}'))