import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String sensorDataId;
  final String alertLevel; // e.g., "ALERT", "DANGER"
  final DateTime timestamp;
  final Map<String, AlertMethodStatus> methods; // delivery method status
  final bool acknowledged;
  final DateTime? acknowledgedAt;
  final String message;

  Alert({
    required this.id,
    required this.sensorDataId,
    required this.alertLevel,
    required this.timestamp,
    required this.methods,
    this.acknowledged = false,
    this.acknowledgedAt,
    required this.message,
  });

  factory Alert.fromMap(Map<String, dynamic> map, String id) {
    return Alert(
      id: id,
      sensorDataId: map['sensorDataId'] ?? '',
      alertLevel: map['alertLevel'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      methods: (map['methods'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(
          key,
          AlertMethodStatus.fromMap(value as Map<String, dynamic>),
        ),
      ),
      acknowledged: map['acknowledged'] ?? false,
      acknowledgedAt: map['acknowledgedAt'] != null
          ? (map['acknowledgedAt'] as Timestamp).toDate()
          : null,
      message: map['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sensorDataId': sensorDataId,
      'alertLevel': alertLevel,
      'timestamp': Timestamp.fromDate(timestamp),
      'methods': methods.map((key, value) => MapEntry(key, value.toMap())),
      'acknowledged': acknowledged,
      'acknowledgedAt': acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
      'message': message,
    };
  }
}

class AlertMethodStatus {
  final bool sent;
  final DateTime? sentAt;
  final bool? acknowledged; // some methods might have acknowledgment

  AlertMethodStatus({
    required this.sent,
    this.sentAt,
    this.acknowledged,
  });

  factory AlertMethodStatus.fromMap(Map<String, dynamic> map) {
    return AlertMethodStatus(
      sent: map['sent'] ?? false,
      sentAt: map['sentAt'] != null ? (map['sentAt'] as Timestamp).toDate() : null,
      acknowledged: map['acknowledged'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sent': sent,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'acknowledged': acknowledged,
    };
  }
}
