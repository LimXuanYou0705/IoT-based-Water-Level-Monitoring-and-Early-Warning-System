import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // collections
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(AppUser user) async {
    await _userCollection.doc(user.uid).set(user.toMap());
  }

}