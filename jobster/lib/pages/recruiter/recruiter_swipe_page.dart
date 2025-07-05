import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobster/main.dart';
import 'package:jobster/utils/constants.dart';

import '../../models/seeker_profile.dart';
import '../../widgets/swipe_seeker_card.dart';
import '../../services/match_service.dart';

class RecruiterSwipePage extends StatefulWidget {
  final void Function(int)? onSwitchTab;

  const RecruiterSwipePage({super.key, this.onSwitchTab});

  @override
  State<RecruiterSwipePage> createState() => _RecruiterSwipePageState();
}

class _RecruiterSwipePageState extends State<RecruiterSwipePage> {
  final _auth = FirebaseAuth.instance;
  List<SeekerProfile> seekers = [];
  List<JobPosting> jobPostings = [];
  JobPosting? selectedJob;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobPostings();
  }

  Future<void> loadJobPostings() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection(CollectionNames.recruiters)
          .doc(currentUser.uid)
          .get();

      final jobRefs = userDoc.data()?['jobs'] as List<dynamic>?;

      if (jobRefs == null || jobRefs.isEmpty) {
        setState(() {
          jobPostings = [];
          selectedJob = null;
          seekers = [];
          isLoading = false;
        });
        return;
      }

      final fetchedJobs = <JobPosting>[];

      for (final ref in jobRefs) {
        DocumentSnapshot<Map<String, dynamic>> jobSnap;

        if (ref is String) {
          // ref is job document ID
          jobSnap = await FirebaseFirestore.instance
              .collection(CollectionNames.jobs)
              .doc(ref)
              .get();
        } else {
          // Unknown type, skip
          continue;
        }

        if (jobSnap.exists) {
          fetchedJobs.add(JobPosting.fromMap(jobSnap.id, jobSnap.data()!));
        }
      }

      setState(() {
        jobPostings = fetchedJobs;
        selectedJob = fetchedJobs.isNotEmpty ? fetchedJobs[0] : null;
      });

      // Load seekers only if jobs exist
      await loadSeekers();
    } catch (e) {
      debugPrint('Failed to load job postings: $e');
      setState(() {
        jobPostings = [];
        selectedJob = null;
        seekers = [];
        isLoading = false;
      });
    }
  }

  Future<void> loadSeekers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('seekers')
          .get();

      final fetchedSeekers = snapshot.docs
          .map((doc) => SeekerProfile.fromMap(doc.id, doc.data()))
          .toList();

      setState(() {
        seekers = fetchedSeekers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load seekers: $e');
      setState(() {
        seekers = [];
        isLoading = false;
      });
    }
  }

  void onSwipeRight(SeekerProfile seeker) {
    final currentUser = _auth.currentUser;
    if (currentUser == null || selectedJob == null) return;

    MatchService().handleSwipe(
      seekerId: seeker.id,
      jobId: selectedJob!.id,
      isSeeker: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Talent')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jobPostings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No job postings yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Job Now'),
                    onPressed: () {
                      widget.onSwitchTab?.call(3);
                    },
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButton<JobPosting>(
                    isExpanded: true,
                    value: selectedJob,
                    onChanged: (job) {
                      setState(() {
                        selectedJob = job;
                      });
                    },
                    items: jobPostings.map((job) {
                      return DropdownMenuItem<JobPosting>(
                        value: job,
                        child: Text(job.title),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: seekers.isEmpty
                      ? const Center(child: Text('No seekers found.'))
                      : CardSwiper(
                          cardsCount: seekers.length,
                          numberOfCardsDisplayed: 1,
                          cardBuilder:
                              (
                                context,
                                index,
                                horizontalSwipePercent,
                                verticalSwipePercent,
                              ) {
                                return SwipeSeekerCard(profile: seekers[index]);
                              },
                          onSwipe: (previousIndex, currentIndex, direction) {
                            if (direction == CardSwiperDirection.right) {
                              onSwipeRight(seekers[previousIndex]);
                            }
                            return true;
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
