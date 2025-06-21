import 'package:cloud_firestore/cloud_firestore.dart';

class SensorData {
  final String id;
  final bool danger;
  final double distance;
  final Timestamp timestamp;

  SensorData({
    required this.id,
    required this.danger,
    required this.distance,
    required this.timestamp,
  });

  factory SensorData.fromMap(Map<String, dynamic> map, String id) {
    return SensorData(
      id: id,
      danger: map['danger'] ?? false,
      distance: map['distance']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'danger': danger,
      'distance': distance,
      'timestamp': timestamp,
    };
  }
}