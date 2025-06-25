import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'app.dart';

// app.dart
import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';
import 'widgets/bottom_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const JobTinderApp());
}

class JobTinderApp extends StatelessWidget {
  const JobTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

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

// models/match.dart
class Match {
  final String id;
  final List<String> userIds;

  Match({required this.id, required this.userIds});

  factory Match.fromMap(String id, Map<String, dynamic> data) {
    return Match(id: id, userIds: List<String>.from(data['userIds'] ?? []));
  }

  Map<String, dynamic> toMap() {
    return {'userIds': userIds};
  }
}

// models/message.dart
class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      text: data['text'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
