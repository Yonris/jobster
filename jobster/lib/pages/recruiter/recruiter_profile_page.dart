import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecruiterProfilePage extends StatelessWidget {
  const RecruiterProfilePage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection('recruiters').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile data not found.'));
          }

          final data = snapshot.data!.data()!;
          final fullName = '${data['firstName']} ${data['lastName']}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      data['photo'] != null && data['photo'].isNotEmpty
                      ? NetworkImage(data['photo'])
                      : AssetImage('assets/default_profile.png')
                            as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(data['email'], style: const TextStyle(fontSize: 16)),
                const Divider(height: 32, thickness: 1),

                _buildInfoTile('Age', data['age'].toString()),
                _buildInfoTile('Bio', data['bio']),
                _buildInfoTile('Occupation', data['occupation']),
                _buildInfoTile('City', data['city']),
                _buildInfoTile('Country', data['country']),
                _buildInfoTile(
                  'Account Created',
                  _formatDate(data['createdAt']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day} ${_monthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
