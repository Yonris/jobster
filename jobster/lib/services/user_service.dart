
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final usersRef = FirebaseFirestore.instance.collection('users');

  Future<String> getUserType(String uid) async {
    final doc = await usersRef.doc(uid).get();
    return doc['type'];
  }
}
