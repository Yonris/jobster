import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobster/widgets/home_navigation.dart';

class RecruiterFormStep2 extends StatefulWidget {
  final Map<String, dynamic> data;

  RecruiterFormStep2({super.key, required this.data});

  @override
  State<RecruiterFormStep2> createState() => _RecruiterFormStep2State();
}

class _RecruiterFormStep2State extends State<RecruiterFormStep2> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.data); // Copy passed data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Occupation'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your occupation'
                    : null,
                onSaved: (val) => _data['occupation'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a short bio' : null,
                onSaved: (val) => _data['bio'] = val,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) throw Exception("User not logged in");

                      final uid = user.uid;

                      await FirebaseFirestore.instance
                          .collection('recruiters')
                          .doc(uid)
                          .set({
                            'uid': uid,
                            'email': user.email,
                            'firstName': _data['firstName'],
                            'lastName': _data['lastName'],
                            'age': _data['age'],
                            'country': _data['country'],
                            'city': _data['city'],
                            'occupation': _data['occupation'],
                            'bio': _data['bio'],
                            'photo': _data['photo'],
                            'type': 'recruiter',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile saved! Logging in...'),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserHomeNavigation(userData: {"role": "recruiter"}),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
