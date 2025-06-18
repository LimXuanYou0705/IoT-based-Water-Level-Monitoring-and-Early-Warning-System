import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profilePicture;
  int contributionScore;
  final String status;
  final List<String> alertChannels;
  final DateTime createdAt;
  DateTime? lastLogin;
  final bool isPhoneVerified;

  // Constructor
  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePicture,
    required this.contributionScore,
    required this.status,
    required this.alertChannels,
    required this.createdAt,
    this.lastLogin,
    required this.isPhoneVerified,
  });

  // Method to convert a User object to a Map (useful for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profilePicture': profilePicture,
      'contributionScore': contributionScore,
      'status': status,
      'alertChannels': alertChannels,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'isPhoneVerified': isPhoneVerified,
    };
  }

  // Method to create a User object from a Firestore document (Map)
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return User(
      userId: doc.id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      role: data['role'],
      profilePicture: data['profilePicture'],
      contributionScore: data['contributionScore'],
      status: data['status'],
      alertChannels: List<String>.from(data['alertChannels']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isPhoneVerified: data['isPhoneVerified'] ?? false,
    );
  }
}