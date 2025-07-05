class SeekerProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? bio;

  SeekerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.bio,
  });

  factory SeekerProfile.fromMap(String id, Map<String, dynamic> data) {
    return SeekerProfile(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'bio': bio,
    };
  }
}
