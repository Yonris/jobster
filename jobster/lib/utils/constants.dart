class UserType {
  static const String recruiter = 'recruiter';
  static const String seeker = 'seeker';
  static const String newUser = 'newUser';
}

class CollectionNames {
  static const String seekers = 'seekers';
  static const String recruiters = 'recruiters';
  static const String jobs = 'jobs';
  static const String matches = 'matches';
  static const String jobMatches = 'jobMatches';
}

class SeekerFieldKeys {
  static const String bio = 'bio';
  static const String city = 'city';
  static const String country = 'country';
  static const String createdAt = 'createdAt';
  static const String email = 'email';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String likedJobs = 'likedJobs';
  static const String occupation = 'occupation';
  static const String photo = 'photo';
  static const String type = 'type';
  static const String uid = 'uid';
  static const String matches = 'matches';
}

class RecruiterFieldKeys {
  static const String age = 'age';
  static const String bio = 'bio';
  static const String city = 'city';
  static const String country = 'country';
  static const String createdAt = 'createdAt';
  static const String email = 'email';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String occupation = 'occupation';
  static const String photo = 'photo';
  static const String type = 'type';
  static const String uid = 'uid';
  static const String jobs = 'jobs';
}

class JobFieldKeys {
  static const String company = 'company';
  static const String title = 'title';
  static const String description = 'description';
  static const String location = 'location';
  static const String educationRequirments = 'educationRequirements';
  static const String experienceRequirements = 'experienceRequirements';
  static const String languageRequirements = 'languageRequirements';
  static const String technicalRequirements = 'technicalRequirements';
  static const String environmenRequirements = 'environmenRequirements';
  static const String recruiterLikes = 'recruiterLikes';
  static const String seekerLikes = 'seekerLikes';
  static const String matches = 'matches';
  static const String ownerId = 'ownerId';
  static const String timestamp = 'timestamp';
  static const String companyName = 'companyName';
}

class MatchFieldKeys {
  static const String seekerId = 'seekerId';
  static const String recruiterId = 'recruiterId';
  static const String companyName = JobFieldKeys.companyName;
  static const String jobId = 'jobId';
  static const String timestamp = 'timestamp';
}

class RequirementTypes {
  static const String educationRequirements = 'educationRequirements';
  static const String experienceRequirements = 'experienceRequirements';
  static const String languageRequirements = 'languageRequirements';
  static const String technicalRequirements = 'technicalRequirements';
  static const String environmentRequirements = 'environmentRequirements';
}
