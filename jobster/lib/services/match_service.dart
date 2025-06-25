import 'package:cloud_firestore/cloud_firestore.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> handleSwipe({
    required String currentUserId,
    required String targetId,
  }) async {
    // Check if target already liked current user for a match
    final query = await _firestore
        .collection('jobs')
        .where('likes', arrayContains: currentUserId)
        .get();

    // Store swipe info under 'jobs' collection
    await _firestore.collection('jobs').doc(targetId).update({
      'likes': FieldValue.arrayUnion([currentUserId]),
    });

    

    if (query.docs.isNotEmpty) {
      // Create match document
      await _firestore.collection('seekers').doc(currentUserId).update({
        'matches': FieldValue.arrayUnion([targetId]),
      });
    }
  }
}
