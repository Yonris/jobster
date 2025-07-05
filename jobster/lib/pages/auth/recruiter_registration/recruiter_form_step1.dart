import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'package:jobster/pages/auth/recruiter_registration/recruiter_form_step2.dart';

class RecruiterFormStep1 extends StatefulWidget {
  const RecruiterFormStep1({super.key});

  @override
  State<RecruiterFormStep1> createState() => _RecruiterFormStep1State();
}

class _RecruiterFormStep1State extends State<RecruiterFormStep1> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};
  File? _selectedImage;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
        ],
      );

      if (croppedFile != null) {
        if (!mounted) return;
        setState(() {
          _selectedImage = File(croppedFile.path);
          _uploading = true;
        });

        try {
          final fileName = path.basename(croppedFile.path);
          final storageRef = FirebaseStorage.instance.ref().child(
            'profile_photos/$fileName',
          );

          final uploadTask = await storageRef.putFile(File(croppedFile.path));
          final downloadUrl = await uploadTask.ref.getDownloadURL();

          setState(() {
            _data['photo'] = downloadUrl;
            _uploading = false;
          });
        } catch (e) {
          setState(() => _uploading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Basics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _uploading ? null : _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your first name'
                    : null,
                onSaved: (val) => _data['firstName'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your last name'
                    : null,
                onSaved: (val) => _data['lastName'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your age' : null,
                keyboardType: TextInputType.number,
                onSaved: (val) => _data['age'] = int.tryParse(val ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your country'
                    : null,
                onSaved: (val) => _data['country'] = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your city' : null,
                onSaved: (val) => _data['city'] = val,
              ),
              const SizedBox(height: 24),
              _uploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecruiterFormStep2(data: _data),
                            ),
                          );
                        }
                      },
                      child: const Text('Continue'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
