import 'package:cloud_firestore/cloud_firestore.dart';

class SensorData {
  final String id;
  final double distance1;
  final double distance2;
  final String levelHighRegion;
  final String levelLowRegion;
  final int rainAnalog;
  final int waterLevelAnalog;
  final Timestamp timestamp;

  SensorData({
    required this.id,
    required this.distance1,
    required this.distance2,
    required this.levelHighRegion,
    required this.levelLowRegion,
    required this.rainAnalog,
    required this.waterLevelAnalog,
    required this.timestamp,
  });

  factory SensorData.fromMap(Map<String, dynamic> map, String id) {
    return SensorData(
      id: id,
      distance1: map['distance1']?.toDouble() ?? 0.0,
      distance2: map['distance2']?.toDouble() ?? 0.0,
      levelHighRegion: map['levelHighRegion'] ?? 'UNKNOWN',
      levelLowRegion: map['levelLowRegion'] ?? 'UNKNOWN',
      rainAnalog: map['rainAnalog'] ?? 0,
      waterLevelAnalog: map['waterLevelAnalog'] ?? 0,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distance1': distance1,
      'distance2': distance2,
      'levelHighRegion': levelHighRegion,
      'levelLowRegion': levelLowRegion,
      'rainAnalog': rainAnalog,
      'waterLevelAnalog': waterLevelAnalog,
      'timestamp': timestamp,
    };
  }
}
