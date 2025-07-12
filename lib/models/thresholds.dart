class RegionThresholds {
  final Thresholds highRegion;
  final Thresholds lowRegion;

  RegionThresholds({required this.highRegion, required this.lowRegion});

  Map<String, dynamic> toMap() {
    return {'high_region': highRegion.toMap(), 'low_region': lowRegion.toMap()};
  }

  factory RegionThresholds.fromMap(Map<String, dynamic> map) {
    final highRegionMap = map['high_region'] as Map<String, dynamic>;
    final lowRegionMap = map['low_region'] as Map<String, dynamic>;

    return RegionThresholds(
      highRegion: Thresholds.fromMap(highRegionMap),
      lowRegion: Thresholds.fromMap(lowRegionMap),
    );
  }
}

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
      danger:
          (map['danger_threshold'] ?? 25.0) is int
              ? (map['danger_threshold'] as int).toDouble()
              : (map['danger_threshold'] as double?) ?? 25.0,

      alert:
          (map['alert_threshold'] ?? 35.0) is int
              ? (map['alert_threshold'] as int).toDouble()
              : (map['alert_threshold'] as double?) ?? 35.0,

      safe:
          (map['safe_threshold'] ?? 45.0) is int
              ? (map['safe_threshold'] as int).toDouble()
              : (map['safe_threshold'] as double?) ?? 45.0,
    );
  }
}
