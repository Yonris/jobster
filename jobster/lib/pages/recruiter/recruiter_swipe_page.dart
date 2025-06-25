import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/job_posting.dart';
import '../../widgets/swipe_card.dart';
import '../../services/match_service.dart';

class RecruiterSwipePage extends StatefulWidget {
  const RecruiterSwipePage({super.key});

  @override
  State<RecruiterSwipePage> createState() => _RecruiterSwipePageState();
}

class _RecruiterSwipePageState extends State<RecruiterSwipePage> {
  final _auth = FirebaseAuth.instance;
  List<JobPosting> jobs = [];

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  Future<void> loadJobs() async {
    final snapshot = await FirebaseFirestore.instance.collection('jobs').get();
    setState(() {
      jobs = snapshot.docs
          .map((doc) => JobPosting.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  void onSwipeRight(JobPosting job) {
    MatchService().handleSwipe(
      currentUserId: _auth.currentUser!.uid,
      targetId: job.recruiterId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Jobs')),
      body: jobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          :CardSwiper(
  cardsCount: jobs.length,
  numberOfCardsDisplayed: 3,
  cardBuilder: (context, index, horizontalSwipePercent, verticalSwipePercent) {
    return SwipeCard(data: jobs[index]);
  },
  onSwipe: (previousIndex, currentIndex, direction) {
    if (direction == CardSwiperDirection.right) {
      onSwipeRight(jobs[previousIndex]);
    }
    return true; // Allow the swipe
    },

),
    );
  }
}
