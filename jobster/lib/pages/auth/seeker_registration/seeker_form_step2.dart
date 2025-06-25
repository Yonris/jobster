import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobster/pages/job_seeker/seeker_home_page.dart';

class SeekerFormStep2 extends StatefulWidget {
  const SeekerFormStep2({super.key});

  @override
  State<SeekerFormStep2> createState() => _SeekerFormStep2State();
}

class _SeekerFormStep2State extends State<SeekerFormStep2> {
  final _formKey = GlobalKey<FormState>();
  final _data = <String, dynamic>{};

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
                validator: (value) =>
                    value!.isEmpty ? 'Enter your occupation' : null,
                onSaved: (val) => _data['occupation'] = val,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        final uid = user.uid;

                        // Save additional user data to Firestore

                        await FirebaseFirestore.instance
                            .collection('seekers')
                            .doc(uid)
                            .set({
                              'email': FirebaseAuth.instance.currentUser!.email,
                              'occupation': _data['occupation'],
                              'createdAt': FieldValue.serverTimestamp(),
                              'photo': _data['photo']
                            });

                        // Show success and optionally navigate
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Loging In!')),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SeekerHomePage(),
                          ),
                        );

                        // Optionally navigate to a new page
                        // Navigator.pushReplacement(context, MaterialPageRoute(
                        //   builder: (_) => const HomePage(),
                        // ));
                      } else {
                        throw Exception("User not logged in");
                      }
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
