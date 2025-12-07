class User {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String? fullName;
  final String? gender;
  final String? dateOfBirth;
  final String? preferredPosition;
  final int matchesPlayed;
  final bool isLookingForTeam;
  final bool isBlocked;
  final String role;
  final int? futsalId;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.preferredPosition,
    this.matchesPlayed = 0,
    this.isLookingForTeam = false,
    this.isBlocked = false,
    this.role = 'USER',
    this.futsalId,
  });

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      preferredPosition: json['preferred_position'],
      matchesPlayed: json['matches_played'] ?? 0,
      isLookingForTeam: json['is_looking_for_team'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      role: json['role'] ?? 'USER',
      futsalId: json['futsal'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'preferred_position': preferredPosition,
      'matches_played': matchesPlayed,
      'is_looking_for_team': isLookingForTeam,
      'is_blocked': isBlocked,
      'role': role,
      'futsal': futsalId,
    };
  }

  // Helper methods
  bool get isOwner => role == 'OWNER';
  bool get isAdmin => role == 'ADMIN';
  bool get isRegularUser => role == 'USER';

  // Copy with method for updates
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? phone,
    String? fullName,
    String? gender,
    String? dateOfBirth,
    String? preferredPosition,
    int? matchesPlayed,
    bool? isLookingForTeam,
    bool? isBlocked,
    String? role,
    int? futsalId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      preferredPosition: preferredPosition ?? this.preferredPosition,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      isLookingForTeam: isLookingForTeam ?? this.isLookingForTeam,
      isBlocked: isBlocked ?? this.isBlocked,
      role: role ?? this.role,
      futsalId: futsalId ?? this.futsalId,
    );
  }
}
