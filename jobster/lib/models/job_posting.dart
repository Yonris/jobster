// models/job_posting.dart
class JobPosting {
  final String id;
  final String recruiterId;
  final String title;
  final String description;
  final List<String> requirements;
  final String location;

  JobPosting({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
  });

  factory JobPosting.fromMap(String id, Map<String, dynamic> data) {
    return JobPosting(
      id: id,
      recruiterId: data['recruiterId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recruiterId': recruiterId,
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
    };
  }
}
