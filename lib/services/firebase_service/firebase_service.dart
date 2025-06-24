import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sensor_data.dart';
import '../../models/thresholds.dart';
import '../../models/user.dart';

class FirebaseService {
  // collections
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _sensorDataCollection = FirebaseFirestore.instance.collection('sensorData');

  // document
  final DocumentReference _thresholdsDoc = FirebaseFirestore.instance.collection('config').doc('thresholds');

  Future<void> createUser(AppUser user) async {
    await _userCollection.doc(user.uid).set(user.toMap());
  }

  // get list of sensor data record
  Stream<List<SensorData>> getSensorData() {
    return _sensorDataCollection
        .orderBy('timestamp', descending: true) // Sort by timestamp in order
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SensorData.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
    return _sensorDataCollection.where('level', whereIn: ['ALERT', 'DANGER']).orderBy('timestamp', descending: true).limit(50).snapshots().map((snapshot){
      return snapshot.docs.map((doc) {
        return SensorData.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
    final query = await _sensorDataCollection
        .where('level', whereIn: ['ALERT', 'DANGER'])
        .where('seen', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      await doc.reference.update({'seen': true});
    }
  }

  // get latest thresholds data
  Stream<Thresholds> getThresholds() {
    return _thresholdsDoc.snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return Thresholds.fromMap(data ?? {});
    });
  }

}