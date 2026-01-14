class Team {
  final int id;
  final String name;
  final String description;
  final int captain;
  final String captainName;
  final int memberCount;
  final int matchesCount;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.captain,
    required this.captainName,
    required this.memberCount,
    required this.matchesCount,
    required this.createdAt,
  });

  // Convert JSON from API to Team object
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      captain: json['captain'] ?? 0,
      captainName: json['captain_name'] ?? 'Unknown',
      memberCount: json['member_count'] ?? 0,
      matchesCount: json['matches_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
