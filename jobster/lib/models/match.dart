
// models/match.dart
class Match {
  final String id;
  final List<String> userIds;

  Match({
    required this.id,
    required this.userIds,
  });

  factory Match.fromMap(String id, Map<String, dynamic> data) {
    return Match(
      id: id,
      userIds: List<String>.from(data['userIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
    };
  }
}