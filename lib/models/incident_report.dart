import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentReport {
  final String reportId;
  final String userId;
  final String incidentTypeId;
  final String locationString;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final String status; // e.g. "Pending", "Approved", "Rejected"
  final String? adminNotes;
  final int reactionCount;
  final int shareCount;
  final String? amendmentRequest;
  final int pointsAwarded;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? processedBy;
  final Timestamp? processedAt;

  IncidentReport({
    required this.reportId,
    required this.userId,
    required this.incidentTypeId,
    required this.locationString,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    required this.status,
    this.adminNotes,
    required this.reactionCount,
    required this.shareCount,
    this.amendmentRequest,
    required this.pointsAwarded,
    required this.createdAt,
    required this.updatedAt,
    this.processedBy,
    this.processedAt,
  });

  factory IncidentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncidentReport(
      reportId: doc.id,
      userId: data['user_id'],
      incidentTypeId: data['incident_type_id'],
      locationString: data['location_string'],
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      title: data['title'],
      description: data['description'],
      imageUrl: data['image_url'],
      videoUrl: data['video_url'],
      status: data['status'],
      adminNotes: data['admin_notes'],
      reactionCount: data['reaction_count'] ?? 0,
      shareCount: data['share_count'] ?? 0,
      amendmentRequest: data['amendment_request'],
      pointsAwarded: data['points_awarded'] ?? 0,
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      processedBy: data['processed_by'],
      processedAt: data['processed_at'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'incident_type_id': incidentTypeId,
      'location_string': locationString,
      'latitude': latitude,
      'longitude': longitude,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'status': status,
      'admin_notes': adminNotes,
      'reaction_count': reactionCount,
      'share_count': shareCount,
      'amendment_request': amendmentRequest,
      'points_awarded': pointsAwarded,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'processed_by': processedBy,
      'processed_at': processedAt,
    };
  }
}
