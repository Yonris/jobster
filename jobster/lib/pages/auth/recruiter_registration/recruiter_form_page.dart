// seeker_form_page.dart
import 'package:flutter/material.dart';
import '../base_register_page.dart';
class RecruiterFormPage extends StatelessWidget {
  const RecruiterFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final _ageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Tell us about yourself')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // You can pass this info to the next page if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
