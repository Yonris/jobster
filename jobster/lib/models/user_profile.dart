

// models/user_profile.dart
class UserProfile {
  final String id;
  final String name;
  final String type; // 'seeker' or 'recruiter'
  final String bio;
  final String imageUrl;
  final List<String> skills;

  UserProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.bio,
    required this.imageUrl,
    required this.skills,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'seeker',
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'bio': bio,
      'imageUrl': imageUrl,
      'skills': skills,
    };
  }
}