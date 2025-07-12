import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/Alert.dart';
import '../../models/sensor_data.dart';
import '../../models/thresholds.dart';
import '../../models/user.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  // collections
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');
  final CollectionReference _sensorDataCollection = FirebaseFirestore.instance
      .collection('sensorData');
  final CollectionReference _alertCollection = FirebaseFirestore.instance
      .collection('alerts');

  // document
  final DocumentReference _thresholdsDoc = FirebaseFirestore.instance
      .collection('thresholds')
      .doc('region_settings');

  // store FCM tokens
  Future<void> saveFcmToken(String userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
      });
    }
  }

  // Sensor Status
  Stream<bool> getSensorStatus() {
    return FirebaseFirestore.instance
        .collection('sensorStatus')
        .doc('sensor_001')
        .snapshots()
        .map((doc) => doc.data()?['online'] ?? false);
  }

  // User things

  // stream of the current user
  Stream<AppUser?> streamUserProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _userCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );
      } else {
        return null;
      }
    });
  }

  Future<void> updateUserName(String newName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _userCollection.doc(uid).update({'name': newName});
    }
  }

  Future<void> createUser(AppUser user) async {
    await _userCollection.doc(user.uid).set(user.toMap());
  }

  Future<List<AppUser>> getAllUsersWithAlertChannels() async {
    final snapshot =
        await _userCollection.where('alertChannels', isNotEqualTo: []).get();

    return snapshot.docs
        .map(
          (doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  Future<AppUser?> getUserById(String uid) async {
    final doc = await _userCollection.doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<String>> getAlertChannels(String uid) async {
    final doc = await _userCollection.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final channels = data['alertChannels'] ?? [];
      return List<String>.from(channels);
    }
    return [];
  }

  Future<void> updateAlertChannels(String uid, List<String> channels) async {
    await _userCollection.doc(uid).update({'alertChannels': channels});
  }

  // Sensor data things
  // Get list of sensor data records
  Stream<List<SensorData>> getSensorData() {
    return _sensorDataCollection
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SensorData.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Get latest water level for high region
  Stream<double> getHighRegionLatestWaterLevel() {
    return getSensorData().map((dataList) {
      if (dataList.isNotEmpty) {
        return dataList.first.distance1;
      } else {
        return 0.0;
      }
    });
  }
  // Get latest water level for low region
  Stream<double> getLowRegionLatestWaterLevel() {
    return getSensorData().map((dataList) {
      if (dataList.isNotEmpty) {
        return dataList.first.distance2;
      } else {
        return 0.0;
      }
    });
  }

  // Get alert history based on either high or low region being ALERT/DANGER
  Stream<List<SensorData>> getAlertHistory() {
    return _sensorDataCollection
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final data = SensorData.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
                if (['ALERT', 'DANGER'].contains(data.levelHighRegion) ||
                    ['ALERT', 'DANGER'].contains(data.levelLowRegion)) {
                  return data;
                }
                return null;
              })
              .whereType<SensorData>()
              .toList();
        });
  }

  // Count unseen alerts where either high or low region is ALERT/DANGER
  Stream<int> getUnseenAlertCount() {
    return _sensorDataCollection
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final high = data['levelHighRegion'];
            final low = data['levelLowRegion'];
            return ['ALERT', 'DANGER'].contains(high) ||
                ['ALERT', 'DANGER'].contains(low);
          }).length;
        });
  }

  // Mark all unseen ALERT or DANGER alerts as seen
  Future<void> markAllAlertsAsSeen() async {
    final query =
        await _sensorDataCollection.where('seen', isEqualTo: false).get();

    for (var doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final high = data['levelHighRegion'];
      final low = data['levelLowRegion'];
      if (['ALERT', 'DANGER'].contains(high) ||
          ['ALERT', 'DANGER'].contains(low)) {
        await doc.reference.update({'seen': true});
      }
    }
  }

  // Thresholds things
  // get latest thresholds data
  // Stream<Thresholds> getThresholds() {
  //   return _thresholdsDoc.snapshots().map((doc) {
  //     final data = doc.data() as Map<String, dynamic>?;
  //     return Thresholds.fromMap(data ?? {});
  //   });
  // }
  Stream<RegionThresholds> getRegionThresholds() {
    return _thresholdsDoc.snapshots().map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return RegionThresholds.fromMap(data);
      } else {
        // Return default even if no data
        return RegionThresholds(
          highRegion: Thresholds(danger: 25.0, alert: 35.0, safe: 45.0),
          lowRegion: Thresholds(danger: 10.0, alert: 20.0, safe: 30.0),
        );
      }
    });
  }

  // Alert things
  Future<void> saveAlert(Alert alert) async {
    await _alertCollection.add(alert.toMap());
  }

  Stream<List<Alert>> getAlerts() {
    return _alertCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Alert.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await _alertCollection.doc(alertId).update({
      'acknowledged': true,
      'acknowledgedAt': Timestamp.now(),
    });
  }

  // Uploads profile picture to Firebase Storage and returns the download URL
  Future<String> uploadProfilePicture(File imageFile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final ref = _storage.ref().child("profile_pictures/$uid.jpg");

    // Upload the image to Firebase Storage
    final uploadTask = await ref.putFile(imageFile);

    try {
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception("Upload failed with state: ${snapshot.state}");
      }
    } catch (e) {
      print("Upload failed: $e");
      rethrow;
    }
  }

  // Updates user's Firestore document with new photo URL
  Future<void> updateUserProfilePicture(String downloadUrl) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    try {
      await _userCollection.doc(uid).update({"profilePicture": downloadUrl});
    } catch (e) {
      print("updateUserProfilePicture error: $e");
      rethrow;
    }
  }
}
