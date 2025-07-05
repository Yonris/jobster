import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/swipe_card.dart';
import '../../services/match_service.dart';
import '../../utils/constants.dart';
import '../../main.dart';

class SeekerSwipePage extends StatefulWidget {
  const SeekerSwipePage({super.key});

  @override
  State<SeekerSwipePage> createState() => _SeekerSwipePageState();
}

class _SeekerSwipePageState extends State<SeekerSwipePage> {
  final _auth = FirebaseAuth.instance;
  List<JobPosting> jobs = [];

  @override
  void initState() {
    super.initState();
    loadMatchingJobs();
  }

  Future<void> loadMatchingJobs() async {
    final seekerId = _auth.currentUser?.uid;
    if (seekerId  == null) return;

    try {
      final matchesSnapshot = await FirebaseFirestore.instance
          .collection(CollectionNames.seekers)
          .doc(seekerId)
          .collection('jobMatches')
          .orderBy('matchScore', descending: true)
          .get();

      final jobDocs = await Future.wait(
        matchesSnapshot.docs.map((matchDoc) async {
          final jobId = matchDoc.id;
          final jobSnapshot = await FirebaseFirestore.instance
              .collection(CollectionNames.jobs)
              .doc(jobId)
              .get();

          if (jobSnapshot.exists) {
            final job = JobPosting.fromMap(jobSnapshot.id, jobSnapshot.data()!);
            final matchScore = matchDoc.data()['matchScore'].toDouble();
            job.matchScore = matchScore;
            return job;
          }
          return null;
        }),
      );

      final filteredJobs = jobDocs.whereType<JobPosting>().toList();

      if (!mounted) return;
      setState(() {
        jobs = filteredJobs;
      });
    } catch (e) {
      if (mounted) {
        debugPrint('Failed to load matching jobs: $e');
      }
    }
  }

  void onSwipeLeft(JobPosting job) {
    final seekerId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection(CollectionNames.seekers)
        .doc(seekerId)
        .collection(CollectionNames.jobMatches)
        .doc(job.id)
        .delete();
  }

  void onSwipeRight(JobPosting job) {
    if (!mounted) return;
    MatchService().handleSwipe(
      seekerId: _auth.currentUser!.uid,
      jobId: job.id,
      isSeeker: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Jobs')),
      body: jobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.85,
                child: CardSwiper(
                  cardsCount: jobs.length,
                  numberOfCardsDisplayed: 1,
                  cardBuilder:
                      (
                        context,
                        index,
                        horizontalSwipePercent,
                        verticalSwipePercent,
                      ) {
                        return SwipeCard(data: jobs[index]);
                      },
                  onSwipe: (previousIndex, currentIndex, direction) {
                    if (direction == CardSwiperDirection.right) {
                      onSwipeRight(jobs[previousIndex]);
                    } else {
                      onSwipeLeft(jobs[previousIndex]);
                    }
                    return true;
                  },
                ),
              ),
            ),
    );
  }
}
