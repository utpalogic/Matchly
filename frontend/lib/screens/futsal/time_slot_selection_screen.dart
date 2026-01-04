import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/futsal_model.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import 'confirm_booking_screen.dart';

class TimeSlotSelectionScreen extends StatefulWidget {
  final Futsal futsal;
  final Ground ground;

  const TimeSlotSelectionScreen({
    super.key,
    required this.futsal,
    required this.ground,
  });

  @override
  State<TimeSlotSelectionScreen> createState() =>
      _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _timeSlots = [];
  bool _isLoading = false;
  List<dynamic> _selectedTimeSlots =
      []; // Changed to list for multiple selection

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
  }

  Future<void> _fetchTimeSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final url = '/api/timeslots/?ground=${widget.ground.id}&date=$dateStr';
      final response = await ApiService().get(url);

      if (response.statusCode == 200) {
        List<dynamic> slots;

        if (response.data is List) {
          slots = response.data;
        } else if (response.data is Map && response.data['results'] != null) {
          slots = response.data['results'];
        } else {
          slots = [];
        }

        setState(() {
          _timeSlots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching time slots: $e');
      setState(() {
        _isLoading = false;
        _timeSlots = [];
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlots = [];
      });
      _fetchTimeSlots();
    }
  }

  void _toggleSlotSelection(dynamic slot) {
    final isBooked = slot['is_booked'] ?? false;
    if (isBooked) return;

    setState(() {
      final slotId = slot['id'];
      final isSelected = _selectedTimeSlots.any((s) => s['id'] == slotId);

      if (isSelected) {
        // Remove slot
        _selectedTimeSlots.removeWhere((s) => s['id'] == slotId);
      } else {
        // Add slot
        _selectedTimeSlots.add(slot);
        // Sort by start time
        _selectedTimeSlots.sort(
          (a, b) => a['start_time'].compareTo(b['start_time']),
        );
      }
    });
  }

  bool _areSelectedSlotsConsecutive() {
    if (_selectedTimeSlots.length <= 1) return true;

    for (int i = 0; i < _selectedTimeSlots.length - 1; i++) {
      final currentEndTime = _selectedTimeSlots[i]['end_time'];
      final nextStartTime = _selectedTimeSlots[i + 1]['start_time'];

      if (currentEndTime != nextStartTime) {
        return false;
      }
    }
    return true;
  }

  String _getSelectedDuration() {
    if (_selectedTimeSlots.isEmpty) return '';

    final hours = _selectedTimeSlots.length;
    if (hours == 1) {
      return '1 hour';
    } else {
      return '$hours hours';
    }
  }

  String _getSelectedTimeRange() {
    if (_selectedTimeSlots.isEmpty) return '';

    final startTime = _selectedTimeSlots.first['start_time'].substring(0, 5);
    final endTime = _selectedTimeSlots.last['end_time'].substring(0, 5);

    return '$startTime - $endTime';
  }

  @override
  Widget build(BuildContext context) {
    final areConsecutive = _areSelectedSlotsConsecutive();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Select Time Slot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Futsal & Ground Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.futsal.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.futsal.location ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.ground.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEE, MMM dd').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selection Info Banner
          if (_selectedTimeSlots.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: areConsecutive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: areConsecutive ? AppColors.primary : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    areConsecutive ? Icons.check_circle : Icons.warning,
                    color: areConsecutive ? AppColors.primary : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          areConsecutive
                              ? 'Selected: ${_getSelectedDuration()}'
                              : 'Please select consecutive slots',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: areConsecutive
                                ? AppColors.primary
                                : Colors.orange,
                          ),
                        ),
                        if (areConsecutive)
                          Text(
                            _getSelectedTimeRange(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Time Slots Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Time Slots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_selectedTimeSlots.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTimeSlots = [];
                      });
                    },
                    child: Text('Clear', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Time Slots Grid
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _timeSlots.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No time slots available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _timeSlots[index];
                      final isBooked = slot['is_booked'] ?? false;
                      final isSelected = _selectedTimeSlots.any(
                        (s) => s['id'] == slot['id'],
                      );

                      return _buildTimeSlotCard(slot, isBooked, isSelected);
                    },
                  ),
          ),

          // Continue Button
          if (_selectedTimeSlots.isNotEmpty && areConsecutive)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _getSelectedDuration(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _getSelectedTimeRange(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmBookingScreen(
                                futsal: widget.futsal,
                                ground: widget.ground,
                                timeSlots: _selectedTimeSlots,
                                selectedDate: _selectedDate,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Continue (${_selectedTimeSlots.length} ${_selectedTimeSlots.length == 1 ? "slot" : "slots"})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(dynamic slot, bool isBooked, bool isSelected) {
    final startTime = slot['start_time'];
    final timeStr = startTime.substring(0, 5);

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isBooked) {
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade400;
      borderColor = Colors.grey.shade300;
    } else if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
      borderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: isBooked ? null : () => _toggleSlotSelection(slot),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isBooked
                  ? 'Booked'
                  : isSelected
                  ? 'Selected'
                  : 'Available',
              style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
