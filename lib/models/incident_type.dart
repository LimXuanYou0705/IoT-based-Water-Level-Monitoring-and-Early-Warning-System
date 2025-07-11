import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentType {
  final String id;
  final String name;
  final String logo;

  IncidentType({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory IncidentType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncidentType(
      id: doc.id,
      name: data['name'],
      logo: data['logo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logo': logo,
    };
  }
}
