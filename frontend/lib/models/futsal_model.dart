class Futsal {
  final int id;
  final String name;
  final String location;
  final String? description;
  final String contact;
  final bool isActive;
  final double averageRating;
  final int totalReviews;
  final List<Ground>? grounds;

  Futsal({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.contact,
    this.isActive = true,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.grounds,
  });

  factory Futsal.fromJson(Map<String, dynamic> json) {
    return Futsal(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      contact: json['contact'],
      isActive: json['is_active'] ?? true,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      grounds: json['grounds'] != null
          ? (json['grounds'] as List).map((g) => Ground.fromJson(g)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'contact': contact,
      'is_active': isActive,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}

class Ground {
  final int id;
  final int futsalId;
  final String name;
  final double pricePerHour;
  final bool isAvailable;

  Ground({
    required this.id,
    required this.futsalId,
    required this.name,
    required this.pricePerHour,
    this.isAvailable = true,
  });

  factory Ground.fromJson(Map<String, dynamic> json) {
    return Ground(
      id: json['id'],
      futsalId: json['futsal'],
      name: json['name'],
      pricePerHour: (json['price_per_hour']).toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'futsal': futsalId,
      'name': name,
      'price_per_hour': pricePerHour,
      'is_available': isAvailable,
    };
  }
}

class TimeSlot {
  final int id;
  final int groundId;
  final String date;
  final String startTime;
  final String endTime;
  final bool isBooked;

  TimeSlot({
    required this.id,
    required this.groundId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      groundId: json['ground'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isBooked: json['is_booked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ground': groundId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked,
    };
  }
}
