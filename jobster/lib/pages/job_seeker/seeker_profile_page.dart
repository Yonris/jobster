import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SeekerProfilePage extends StatelessWidget {
  const SeekerProfilePage({super.key});

  Future<Map<String, dynamic>> _fetchUserDataWithSkills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in.');

    final userDoc =
        await FirebaseFirestore.instance.collection('seekers').doc(uid).get();
    final userData = userDoc.data();
    if (userData == null) throw Exception('User data not found.');

    final categories = {
      'educationSkills': 'educationRequirements',
      'experienceSkills': 'experienceRequirements',
      'languageSkills': 'languageRequirements',
      'technicalSkills': 'technicalRequirements',
      'environmentSkills': 'environmentRequirements',
    };

    final Map<String, List<String>> skillNamesByCategory = {};

    for (final entry in categories.entries) {
      final ids = List<String>.from(userData[entry.key] ?? []);
      final skillDocs = await Future.wait(ids.map((id) async {
        final doc = await FirebaseFirestore.instance
            .collection('requirements')
            .doc(entry.value)
            .collection('requirement')
            .doc(id)
            .get();
        return doc.exists ? doc['name'] as String : null;
      }));

      skillNamesByCategory[entry.key] =
          skillDocs.whereType<String>().toList(); // remove nulls
    }

    return {
      ...userData,
      ...skillNamesByCategory,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserDataWithSkills(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Profile data not found.'));
          }

          final data = snapshot.data!;
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
                          : const AssetImage('assets/default_profile.png')
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
                _buildInfoTile('City', data['city']),
                _buildInfoTile('Country', data['country']),
                _buildInfoTile(
                  'Account Created',
                  _formatDate(data['createdAt']),
                ),

                const Divider(height: 32, thickness: 1),

                _buildSkillsSection('Education', data['educationSkills']),
                _buildSkillsSection('Experience', data['experienceSkills']),
                _buildSkillsSection('Languages', data['languageSkills']),
                _buildSkillsSection('Technical Skills', data['technicalSkills']),
                _buildSkillsSection('Work Environment', data['environmentSkills']),
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

  Widget _buildSkillsSection(String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        skills.isEmpty
            ? const Text('None selected.', style: TextStyle(color: Colors.grey))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((s) => Chip(label: Text(s))).toList(),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day} ${_monthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
   