import 'package:cloud_firestore/cloud_firestore.dart';

class SensorData {
  final String id;
  final String level;
  final double distance;
  final Timestamp timestamp;

  SensorData({
    required this.id,
    required this.level,
    required this.distance,
    required this.timestamp,
  });

  factory SensorData.fromMap(Map<String, dynamic> map, String id) {
    return SensorData(
      id: id,
      level: map['level'],
      distance: map['distance']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'distance': distance,
      'timestamp': timestamp,
    };
  }
}