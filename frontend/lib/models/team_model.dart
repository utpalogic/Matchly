class Team {
  final int id;
  final String name;
  final int captainId;
  final String? captainName;
  final List<int> memberIds;
  final int maxMembers;
  final String createdAt;

  Team({
    required this.id,
    required this.name,
    required this.captainId,
    this.captainName,
    this.memberIds = const [],
    this.maxMembers = 10,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      captainId: json['captain'],
      captainName: json['captain_name'],
      memberIds: json['members'] != null ? List<int>.from(json['members']) : [],
      maxMembers: json['max_members'] ?? 10,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'captain': captainId,
      'members': memberIds,
      'max_members': maxMembers,
    };
  }

  int get memberCount => memberIds.length;

  bool get isFull => memberIds.length >= maxMembers;
}
