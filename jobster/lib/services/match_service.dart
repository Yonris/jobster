import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobster/utils/constants.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> handleSwipe({
    required String seekerId,
    required String jobId,
    required bool isSeeker,
  }) async {
    final jobRef = _firestore.collection(CollectionNames.jobs).doc(jobId);
    final seekerRef = _firestore.collection(CollectionNames.seekers).doc(seekerId);

    if (isSeeker) {
      // Add seekerId to job's 'seekerLikes'
      await jobRef.update({
        JobFieldKeys.seekerLikes: FieldValue.arrayUnion([seekerId]),
      });
      await seekerRef.update({
        SeekerFieldKeys.likedJobs: FieldValue.arrayUnion([jobId]),
      });
    } else {
      // Add seekerId to job's 'recruiterLikes'
      await jobRef.update({
        JobFieldKeys.recruiterLikes: FieldValue.arrayUnion([seekerId]),
      });
    }

    // Check for mutual match
    final jobDoc = await jobRef.get();
    final jobData = jobDoc.data();
    if (jobData == null) return;

    final List<dynamic> jobLikes = jobData[JobFieldKeys.seekerLikes] ?? [];
    final List<dynamic> recruiterLikes = jobData[JobFieldKeys.recruiterLikes] ?? [];

    if (jobLikes.contains(seekerId) && recruiterLikes.contains(seekerId)) {
      final matchData = {
        MatchFieldKeys.seekerId: seekerId,
        MatchFieldKeys.recruiterId: jobData[JobFieldKeys.ownerId],
        MatchFieldKeys.companyName: jobData[JobFieldKeys.company] ?? '',
        MatchFieldKeys.jobId: jobId,
        MatchFieldKeys.timestamp: FieldValue.serverTimestamp(),
      };

      final matchRef = await _firestore.collection(CollectionNames.matches).add(matchData);

      await Future.wait([
        seekerRef.update({
          SeekerFieldKeys.matches: FieldValue.arrayUnion([matchRef.id]),
        }),
        jobRef.update({
          JobFieldKeys.matches: FieldValue.arrayUnion([matchRef.id]),
        }),
      ]);
    }
  }
}
