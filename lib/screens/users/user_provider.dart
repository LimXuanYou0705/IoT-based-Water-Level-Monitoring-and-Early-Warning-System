import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  StreamSubscription? _subscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppUser? get user => _user;

  UserProvider() {
    _init();
  }

  void _init() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _subscription = _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final updatedUser = AppUser.fromMap(snapshot.data()!, snapshot.id);

        final hasCriticalChange = _user?.role != updatedUser.role;

        _user = updatedUser;
        _isInitialized = true;

        if (hasCriticalChange) {
          notifyListeners();
        }
      }
    });
  }

  void updateProfilePictureLocally(String newUrl) {
    if (_user != null) {
      _user = _user!.copyWith(profilePicture: newUrl);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
