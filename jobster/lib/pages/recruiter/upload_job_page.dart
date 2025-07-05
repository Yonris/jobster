import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobster/utils/constants.dart';

class UploadJobPage extends StatefulWidget {
  const UploadJobPage({super.key});

  @override
  State<UploadJobPage> createState() => _UploadJobPageState();
}

class _UploadJobPageState extends State<UploadJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyNameController = TextEditingController();

  final _selected = {
    RequirementTypes.educationRequirements: <String>[],
    RequirementTypes.experienceRequirements: <String>[],
    RequirementTypes.languageRequirements: <String>[],
    RequirementTypes.technicalRequirements: <String>[],
    RequirementTypes.environmentRequirements: <String>[],
  };

  final _requirementNameMap = <String, Map<String, String>>{};
  bool _isSubmitting = false;

  Future<void> _selectRequirements(String type, String title) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('requirements')
        .doc(type)
        .collection('requirement')
        .get();

    final skillMap = {
      for (var doc in snapshot.docs) doc.id: doc['name'] as String
    };
    _requirementNameMap[type] = skillMap;

    String filter = '';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = skillMap.entries
                .where((entry) =>
                    entry.value.toLowerCase().contains(filter.toLowerCase()))
                .toList();

            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: DraggableScrollableSheet(
                expand: false,
                builder: (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select up to 3 $title',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) =>
                            setModalState(() => filter = val.trim()),
                      ),
                      const SizedBox(height: 10),
                      ...filtered.map((entry) {
                        final selected = _selected[type]!;
                        return CheckboxListTile(
                          title: Text(entry.value),
                          value: selected.contains(entry.key),
                          onChanged: (checked) {
                            setModalState(() {
                              setState(() {
                                if (checked == true) {
                                  if (selected.length < 3) {
                                    selected.add(entry.key);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Maximum 3 selections allowed'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                } else {
                                  selected.remove(entry.key);
                                }
                              });
                            });
                          },
                        );
                      })
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _requirementField(String title, String type) {
    final selected = _selected[type]!;
    final map = _requirementNameMap[type] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _selectRequirements(type, title),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: selected.isEmpty
                ? Text('Tap to select $title',
                    style: const TextStyle(color: Colors.grey))
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selected.map((id) {
                      return Chip(
                        label: Text(map[id] ?? id),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => setState(() => selected.remove(id)),
                      );
                    }).toList(),
                  ),
          ),
        )
      ],
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final jobData = {
        JobFieldKeys.title: _titleController.text.trim(),
        JobFieldKeys.companyName: _companyNameController.text.trim(),
        JobFieldKeys.description: _descriptionController.text.trim(),
        JobFieldKeys.location: _locationController.text.trim(),
        JobFieldKeys.educationRequirments:
            _selected[RequirementTypes.educationRequirements],
        JobFieldKeys.experienceRequirements:
            _selected[RequirementTypes.experienceRequirements],
        JobFieldKeys.languageRequirements:
            _selected[RequirementTypes.languageRequirements],
        JobFieldKeys.technicalRequirements:
            _selected[RequirementTypes.technicalRequirements],
        JobFieldKeys.environmenRequirements:
            _selected[RequirementTypes.environmentRequirements],
        JobFieldKeys.seekerLikes: [],
        JobFieldKeys.recruiterLikes: [],
        JobFieldKeys.matches: [],
        JobFieldKeys.ownerId: user.uid,
        JobFieldKeys.timestamp: Timestamp.now(),
      };

      final jobRef = await FirebaseFirestore.instance
          .collection(CollectionNames.jobs)
          .add(jobData);

      await FirebaseFirestore.instance
          .collection(CollectionNames.recruiters)
          .doc(user.uid)
          .update({
        RecruiterFieldKeys.jobs: FieldValue.arrayUnion([jobRef.id])
      });

      // ✅ Match seekers
      await _matchSeekersToJob(jobRef.id, jobData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully!')),
      );
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _companyNameController.clear();
      setState(() => _selected.forEach((_, list) => list.clear()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _matchSeekersToJob(String jobId, Map<String, dynamic> jobData) async {
    final seekersSnapshot =
        await FirebaseFirestore.instance.collection('seekers').get();

    for (final seekerDoc in seekersSnapshot.docs) {
      final seekerId = seekerDoc.id;
      final seekerData = seekerDoc.data();

      int score = 0;
      for (final type in _selected.keys) {
        final seekerSkills = List<String>.from(seekerData[type] ?? []);
        final jobReqs = List<String>.from(jobData[_getKey(type)] ?? []);
        score += seekerSkills.where((skill) => jobReqs.contains(skill)).length;
      }

      if (score > 0) {
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(jobId)
            .collection('seekerMatches')
            .doc(seekerId)
            .set({
          'matchScore': score,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  String _getKey(String type) {
    switch (type) {
      case RequirementTypes.educationRequirements:
        return JobFieldKeys.educationRequirments;
      case RequirementTypes.experienceRequirements:
        return JobFieldKeys.experienceRequirements;
      case RequirementTypes.languageRequirements:
        return JobFieldKeys.languageRequirements;
      case RequirementTypes.technicalRequirements:
        return JobFieldKeys.technicalRequirements;
      case RequirementTypes.environmentRequirements:
        return JobFieldKeys.environmenRequirements;
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
                maxLines: 3,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              _requirementField('Education Requirements',
                  RequirementTypes.educationRequirements),
              _requirementField('Experience Requirements',
                  RequirementTypes.experienceRequirements),
              _requirementField('Language Requirements',
                  RequirementTypes.languageRequirements),
              _requirementField('Technical Requirements',
                  RequirementTypes.technicalRequirements),
              _requirementField('Environment Requirements',
                  RequirementTypes.environmentRequirements),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitJob,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
