import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobster/pages/auth/login_page.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final matchesRef = FirebaseFirestore.instance.collection('matches');

    return Scaffold(
      appBar: AppBar(title: const Text('Chats'),
       actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const LoginPage()),
  (route) => false, // remove all previous routes
);
      },
    )
  ],),
      body: StreamBuilder<QuerySnapshot>(
        stream: matchesRef.where('userIds', arrayContains: currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final matches = snapshot.data!.docs;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final otherUserId = (matches[index]['userIds'] as List).firstWhere((id) => id != currentUserId);
              return ListTile(
                title: Text('Chat with $otherUserId'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatPage(otherUserId: otherUserId)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
