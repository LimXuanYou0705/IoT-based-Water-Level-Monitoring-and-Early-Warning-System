import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../models/Alert.dart';
import '../../models/sensor_data.dart';
import '../../models/thresholds.dart';
import '../../models/user.dart';

class FirebaseService {
  // collections
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');
  final CollectionReference _sensorDataCollection = FirebaseFirestore.instance
      .collection('sensorData');
  final CollectionReference _alertCollection = FirebaseFirestore.instance
      .collection('alerts');

  // document
  final DocumentReference _thresholdsDoc = FirebaseFirestore.instance
      .collection('config')
      .doc('thresholds');

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
        .doc('status')
        .snapshots()
        .map((doc) => doc.data()?['online'] ?? false);
  }

  // User things
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

  // Sensor data things
  // get list of sensor data record
  Stream<List<SensorData>> getSensorData() {
    return _sensorDataCollection
        .orderBy('timestamp', descending: true) // Sort by timestamp in order
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

  // get latest water level data
  Stream<double> getLatestWaterLevel() {
    return getSensorData().map((dataList) {
      if (dataList.isNotEmpty) {
        return dataList.first.distance; // Now is desc so it get the latest data
      } else {
        return 0.0; // default if no data
      }
    });
  }

  Stream<List<SensorData>> getAlertHistory() {
    return _sensorDataCollection
        .where('level', whereIn: ['ALERT', 'DANGER'])
        .orderBy('timestamp', descending: true)
        .limit(50)
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

  // Get the number of unseen ALERT or DANGER alerts
  Stream<int> getUnseenAlertCount() {
    return _sensorDataCollection
        .where('level', whereIn: ['ALERT', 'DANGER'])
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAllAlertsAsSeen() async {
    final query =
        await _sensorDataCollection
            .where('level', whereIn: ['ALERT', 'DANGER'])
            .where('seen', isEqualTo: false)
            .get();

    for (var doc in query.docs) {
      await doc.reference.update({'seen': true});
    }
  }

  // Thresholds things
  // get latest thresholds data
  Stream<Thresholds> getThresholds() {
    return _thresholdsDoc.snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return Thresholds.fromMap(data ?? {});
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
}
