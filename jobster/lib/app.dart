import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobster/pages/auth/login_page.dart';
import 'package:jobster/pages/job_seeker/seeker_home_page.dart';
import 'package:jobster/pages/recruiter/recruiter_home_page.dart';
import 'package:jobster/widgets/bottom_menu.dart';
import 'services/user_service.dart';

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoginPage();
          return FutureBuilder<String>(
            future: UserService().getUserType(snapshot.data!.uid),
            builder: (context, typeSnapshot) {
              if (!typeSnapshot.hasData) return const CircularProgressIndicator();
              return typeSnapshot.data == 'seeker'
                  ? const HomeNavigation()
                  : const RecruiterHomePage();
            },
          );
        },
      ),
    );
  }
}
