import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobster/widgets/home_navigation.dart';

class SeekerFormStep2 extends StatefulWidget {
  final Map<String, dynamic> data;

  const SeekerFormStep2({super.key, required this.data});

  @override
  State<SeekerFormStep2> createState() => _SeekerFormStep2State();
}

class _SeekerFormStep2State extends State<SeekerFormStep2> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _data;

  List<String> _selectedEducation = [];
  List<String> _selectedExperience = [];
  List<String> _selectedLanguage = [];
  List<String> _selectedTechnical = [];
  List<String> _selectedEnvironment = [];

  Map<String, String> _idToNameMap = {}; // for displaying names from IDs

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.data);
  }

  Future<void> _selectRequirements({
    required String title,
    required String type,
    required List<String> selectedList,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('requirements')
        .doc(type)
        .collection('requirement')
        .get();

    final allOptions = snapshot.docs
        .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
        .toList();

    // Cache ID to Name map for UI
    for (var opt in allOptions) {
      _idToNameMap[opt['id']!] = opt['name']!;
    }

    final tempSelected = List<String>.from(selectedList);
    final searchController = TextEditingController();

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                List<Map<String, String>> filteredOptions = allOptions
                    .where((option) => option['name']!
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList();

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Select $title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: filteredOptions.map((option) {
                            return CheckboxListTile(
                              title: Text(option['name']!),
                              value: tempSelected.contains(option['id']),
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    tempSelected.add(option['id']!);
                                  } else {
                                    tempSelected.remove(option['id']);
                                  }
                                });
                                setState(() {
                                  selectedList
                                    ..clear()
                                    ..addAll(tempSelected);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedList
                              ..clear()
                              ..addAll(tempSelected);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementSelector({
    required String title,
    required String type,
    required List<String> selectedList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectRequirements(
            title: title,
            type: type,
            selectedList: selectedList,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedList.isEmpty
                  ? [
                      Text(
                        'Tap to select $title',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ]
                  : selectedList
                      .map((id) => Chip(label: Text(_idToNameMap[id] ?? id)))
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final uid = user.uid;

      await FirebaseFirestore.instance.collection('seekers').doc(uid).set({
        'email': user.email,
        'firstName': _data['firstName'],
        'lastName': _data['lastName'],
        'age': _data['age'],
        'country': _data['country'],
        'city': _data['city'],
        'photo': _data['photo'],
        'type': 'seeker',
        'educationSkills': _selectedEducation,
        'experienceSkills': _selectedExperience,
        'languageSkills': _selectedLanguage,
        'technicalSkills': _selectedTechnical,
        'environmentSkills': _selectedEnvironment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved! Logging in...')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const UserHomeNavigation(userData: {"role": "seeker"}),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Skills')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildRequirementSelector(
                  title: 'Education',
                  type: 'educationRequirements',
                  selectedList: _selectedEducation,
                ),
                _buildRequirementSelector(
                  title: 'Experience',
                  type: 'experienceRequirements',
                  selectedList: _selectedExperience,
                ),
                _buildRequirementSelector(
                  title: 'Languages',
                  type: 'languageRequirements',
                  selectedList: _selectedLanguage,
                ),
                _buildRequirementSelector(
                  title: 'Technical Skills',
                  type: 'technicalRequirements',
                  selectedList: _selectedTechnical,
                ),
                _buildRequirementSelector(
                  title: 'Work Environment',
                  type: 'environmentRequirements',
                  selectedList: _selectedEnvironment,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
