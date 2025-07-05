import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobster/pages/auth/login_page.dart';
import 'package:jobster/utils/constants.dart';
import '../chat/chat_page.dart';

class SeekerChatListPage extends StatelessWidget {
  const SeekerChatListPage({super.key});

  Future<Map<String, dynamic>?> _getUserInfo(
    String userType,
    String uid,
  ) async {
    final doc = await FirebaseFirestore.instance
        .collection(userType)
        .doc(uid)
        .get();
    return doc.exists ? doc.data() : null;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _getLastMessage(
    String matchId,
  ) async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection(CollectionNames.matches)
        .doc(matchId)
        .collection(
          'messages',
        ) // If this is reused often, consider adding to constants
        .orderBy(MatchFieldKeys.timestamp, descending: true)
        .limit(1)
        .get();

    return messagesSnapshot.docs.isNotEmpty
        ? messagesSnapshot.docs.first
        : null;
  }

  String getChatId(String a, String b) =>
      a.hashCode <= b.hashCode ? '${a}_$b' : '${b}_$a';

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final matchesRef = FirebaseFirestore.instance.collection(
      CollectionNames.matches,
    );

    final chatStream = matchesRef
        .where(MatchFieldKeys.seekerId, isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: chatStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final matches = snap.data ?? [];
          if (matches.isEmpty) return const Center(child: Text('No chats yet'));

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, i) {
              final match = matches[i];
              final seekerId = match[MatchFieldKeys.seekerId];
              final recruiterId = match[MatchFieldKeys.recruiterId];
              final otherUserId = currentUserId == seekerId
                  ? recruiterId
                  : seekerId;
              final otherUserType = currentUserId == seekerId
                  ? CollectionNames.recruiters
                  : CollectionNames.seekers;
              final chatId = match.id;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserInfo(otherUserType, otherUserId),
                builder: (context, userSnap) {
                  final user = userSnap.data;
                  final name = user != null
                      ? '${user[SeekerFieldKeys.firstName]} ${user[SeekerFieldKeys.lastName]} (${match[MatchFieldKeys.companyName]})'
                      : '';
                  final photo = user?[SeekerFieldKeys.photo];

                  return FutureBuilder<
                    QueryDocumentSnapshot<Map<String, dynamic>>?
                  >(
                    future: _getLastMessage(chatId),
                    builder: (context, msgSnap) {
                      final lastMsg = msgSnap.data?.data()?['message'] ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (photo != null && photo.isNotEmpty)
                              ? NetworkImage(photo)
                              : const AssetImage('assets/default_profile.png')
                                    as ImageProvider,
                        ),
                        title: Text(name),
                        subtitle: Text(lastMsg),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(matchId: chatId),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
