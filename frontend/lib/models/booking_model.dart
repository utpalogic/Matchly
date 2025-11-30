class Booking {
  final int id;
  final int userId;
  final int timeSlotId;
  final int? teamId;
  final String status;
  final String paymentStatus;
  final double? amountPaid;
  final String? khaltiToken;
  final String bookingDate;
  final String? groundName;
  final String? futsalName;

  Booking({
    required this.id,
    required this.userId,
    required this.timeSlotId,
    this.teamId,
    this.status = 'PENDING',
    this.paymentStatus = 'PENDING',
    this.amountPaid,
    this.khaltiToken,
    required this.bookingDate,
    this.groundName,
    this.futsalName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user'],
      timeSlotId: json['time_slot'],
      teamId: json['team'],
      status: json['status'] ?? 'PENDING',
      paymentStatus: json['payment_status'] ?? 'PENDING',
      amountPaid: json['amount_paid'] != null
          ? (json['amount_paid']).toDouble()
          : null,
      khaltiToken: json['khalti_token'],
      bookingDate: json['booking_date'],
      groundName: json['ground_name'],
      futsalName: json['futsal_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'time_slot': timeSlotId,
      'team': teamId,
      'status': status,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      'khalti_token': khaltiToken,
      'booking_date': bookingDate,
    };
  }

  bool get isUpcoming =>
      status == 'CONFIRMED' &&
      DateTime.parse(bookingDate).isAfter(DateTime.now());

  bool get isPast =>
      status == 'COMPLETED' ||
      DateTime.parse(bookingDate).isBefore(DateTime.now());
}
