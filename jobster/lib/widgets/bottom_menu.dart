import 'package:flutter/material.dart';
import '../pages/job_seeker/seeker_swipe_page.dart'; // Your swipe page
import '../pages/chat/chat_list_page.dart'; // Placeholder for chats
import '../pages/job_seeker/seeker_profile_page.dart'; // Placeholder for profile

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SeekerSwipePage(),
    ChatListPage(),
    SeekerProfilePage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTap,
        showSelectedLabels: false, // 👈 hides selected label
        showUnselectedLabels: false, // 👈 hides unselected label
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
