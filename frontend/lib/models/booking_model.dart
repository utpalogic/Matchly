class Booking {
  final int id;
  final int userId;
  final int? teamId;
  final int groundId;
  final int timeSlotId;
  final String status;
  final String paymentStatus;
  final double amountPaid;
  final bool isRewardBooking;
  final DateTime bookingDate;
  final String? notes;

  // Additional fields for display
  final String? groundName;
  final String? futsalName;
  final String? timeSlotDate;
  final String? timeSlotStart;
  final String? timeSlotEnd;

  Booking({
    required this.id,
    required this.userId,
    this.teamId,
    required this.groundId,
    required this.timeSlotId,
    required this.status,
    required this.paymentStatus,
    required this.amountPaid,
    required this.isRewardBooking,
    required this.bookingDate,
    this.notes,
    this.groundName,
    this.futsalName,
    this.timeSlotDate,
    this.timeSlotStart,
    this.timeSlotEnd,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user'],
      teamId: json['team'],
      groundId: json['ground'],
      timeSlotId: json['time_slot'],
      status: json['status'] ?? 'CONFIRMED',
      paymentStatus: json['payment_status'] ?? 'PENDING',
      amountPaid: double.parse(json['amount_paid'].toString()),
      isRewardBooking: json['is_reward_booking'] ?? false,
      bookingDate: DateTime.parse(json['booking_date']),
      notes: json['notes'],
      groundName: json['ground_name'],
      futsalName: json['futsal_name'],
      timeSlotDate: json['time_slot_date'],
      timeSlotStart: json['time_slot_start'],
      timeSlotEnd: json['time_slot_end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'team': teamId,
      'ground': groundId,
      'time_slot': timeSlotId,
      'status': status,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      'is_reward_booking': isRewardBooking,
      'booking_date': bookingDate.toIso8601String(),
      'notes': notes,
    };
  }
}
