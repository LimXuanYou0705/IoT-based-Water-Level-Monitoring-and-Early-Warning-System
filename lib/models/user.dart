import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
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
  AppUser({
    required this.uid,
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

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
      profilePicture: map['profilePicture'],
      contributionScore: map['contributionScore'],
      status: map['status'],
      alertChannels: List<String>.from(map['alertChannels']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
      isPhoneVerified: map['isPhoneVerified'] ?? false,
    );
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profilePicture,
    int? contributionScore,
    String? status,
    List<String>? alertChannels,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isPhoneVerified,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      contributionScore: contributionScore ?? this.contributionScore,
      status: status ?? this.status,
      alertChannels: alertChannels ?? this.alertChannels,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }
}