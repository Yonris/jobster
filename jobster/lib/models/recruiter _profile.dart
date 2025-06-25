// models/recruiter_profile.dart
class RecruiterProfile {
  final String id;
  final String name;
  final String bio;
  final String imageUrl;
  final List<String> jobPostings;

  RecruiterProfile({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
    required this.jobPostings,
  });

  factory RecruiterProfile.fromMap(String id, Map<String, dynamic> data) {
    return RecruiterProfile(
      id: id,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      jobPostings: List<String>.from(data['jobPostings'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'jobPostings': jobPostings,
    };
  }
}