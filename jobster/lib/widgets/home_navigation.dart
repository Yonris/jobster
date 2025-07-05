import 'package:flutter/material.dart';

import '../pages/job_seeker/seeker_swipe_page.dart';
import '../pages/job_seeker/seeker_chat_list_page.dart';
import '../pages/job_seeker/seeker_profile_page.dart';

import '../pages/recruiter/recruiter_swipe_page.dart';
import '../pages/recruiter/recruiter_chat_list_page.dart';
import '../pages/recruiter/recruiter_profile_page.dart';
import '../pages/recruiter/upload_job_page.dart';

class UserHomeNavigation extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserHomeNavigation({super.key, required this.userData});

  @override
  State<UserHomeNavigation> createState() => UserHomeNavigationState();
}

class UserHomeNavigationState extends State<UserHomeNavigation> {
  int _currentIndex = 0;

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSeeker = widget.userData['role'] == 'seeker';

    final pages = isSeeker
        ? const [
            SeekerSwipePage(),
            SeekerChatListPage(),
            SeekerProfilePage(),
          ]
        : [
            RecruiterSwipePage(onSwitchTab: switchTab),
            const RecruiterChatListPage(),
            const RecruiterProfilePage(),
            const UploadJobPage(),
          ];

    final navItems = isSeeker
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.work), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.work), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ''),
          ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
