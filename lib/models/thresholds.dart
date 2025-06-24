class Thresholds {
  final double danger;
  final double alert;
  final double safe;

  Thresholds({required this.danger, required this.alert, required this.safe});

  Map<String, dynamic> toMap() {
    return {
      'danger_threshold': danger,
      'alert_threshold': alert,
      'safe_threshold': safe,
    };
  }

  factory Thresholds.fromMap(Map<String, dynamic> map) {
    return Thresholds(
      danger: (map['danger_threshold'] ?? 25).toDouble(),
      alert: (map['alert_threshold'] ?? 35).toDouble(),
      safe: (map['safe_threshold'] ?? 45).toDouble(),
    );
  }
}
