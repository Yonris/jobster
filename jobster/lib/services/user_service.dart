import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobster/utils/constants.dart';

class UserService {
  final seekers = FirebaseFirestore.instance.collection(CollectionNames.seekers);
  final recruiters = FirebaseFirestore.instance.collection(CollectionNames.recruiters);
  Future<String> getUserType(String uid) async {
    var doc = await seekers.doc(uid).get();
    if (doc.exists) {
      return UserType.seeker;
    }
    doc = await recruiters.doc(uid).get();
    if (doc.exists) {
      return UserType.recruiter;
    }
    return UserType.newUser;
  }

  Future<String> getUserTypeByEmail(String email) async {
    var doc = await seekers.where('email', isEqualTo: email).get();
    if (doc.docs.isNotEmpty) {
      return UserType.seeker;
    }
    doc = await recruiters.where('email', isEqualTo: email).get();
    if (doc.docs.isNotEmpty) {
      return UserType.recruiter;
    }
    return UserType.newUser;
  }

  Future<void> createNewUser(String uid, String email, String name) async {
    // You can modify this logic to insert into the correct collection or show a role selection first.
    await seekers.doc(uid).set({
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
