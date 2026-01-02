class Futsal {
  final int id;
  final String name;
  final String? location;
  final String? description;
  final String? contact;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;
  final List<Ground>? grounds;

  Futsal({
    required this.id,
    required this.name,
    this.location,
    this.description,
    this.contact,
    this.image,
    required this.isActive,
    this.createdAt,
    this.grounds,
  });

  factory Futsal.fromJson(Map<String, dynamic> json) {
    return Futsal(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      contact: json['contact'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      grounds: json['grounds'] != null
          ? (json['grounds'] as List)
                .map((ground) => Ground.fromJson(ground))
                .toList()
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
      'image': image, // ADD THIS
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Ground {
  final int id;
  final String name;
  final double pricePerHour;
  final bool isAvailable;
  final int futsal;

  Ground({
    required this.id,
    required this.name,
    required this.pricePerHour,
    required this.isAvailable,
    required this.futsal,
  });

  factory Ground.fromJson(Map<String, dynamic> json) {
    return Ground(
      id: json['id'],
      name: json['name'],
      pricePerHour: double.parse(json['price_per_hour'].toString()),
      isAvailable: json['is_available'] ?? true,
      futsal: json['futsal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_per_hour': pricePerHour,
      'is_available': isAvailable,
      'futsal': futsal,
    };
  }
}
