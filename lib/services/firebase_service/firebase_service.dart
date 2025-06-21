import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/sensor_data.dart';
import '../../models/user.dart';

class FirebaseService {
  // collections
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _sensorDataCollection = FirebaseFirestore.instance.collection('sensorData');

  Future<void> createUser(AppUser user) async {
    await _userCollection.doc(user.uid).set(user.toMap());
  }

  // get list of sensor data record
  Stream<List<SensorData>> getSensorData() {
    return _sensorDataCollection
        .orderBy('timestamp', descending: true) // Sort by timestamp in order
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
        return dataList.first.distance; // Assuming latest is first (you sorted descending)
      } else {
        return 0.0; // default if no data
      }
    });
  }

}