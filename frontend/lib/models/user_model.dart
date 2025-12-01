class User {
  final int id;
  final String username;
  final String email;
  final String? phone;
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
    this.preferredPosition,
    this.matchesPlayed = 0,
    this.isLookingForTeam = false,
    this.isBlocked = false,
    this.role = 'USER',
    this.futsalId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      preferredPosition: json['preferred_position'],
      matchesPlayed: json['matches_played'] ?? 0,
      isLookingForTeam: json['is_looking_for_team'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      role: json['role'] ?? 'USER',
      futsalId: json['futsal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'preferred_position': preferredPosition,
      'matches_played': matchesPlayed,
      'is_looking_for_team': isLookingForTeam,
      'is_blocked': isBlocked,
      'role': role,
      'futsal': futsalId,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? phone,
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
      preferredPosition: preferredPosition ?? this.preferredPosition,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      isLookingForTeam: isLookingForTeam ?? this.isLookingForTeam,
      isBlocked: isBlocked ?? this.isBlocked,
      role: role ?? this.role,
      futsalId: futsalId ?? this.futsalId,
    );
  }
}
