import 'package:cloud_firestore/cloud_firestore.dart';

class RecruiterProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  RecruiterProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory RecruiterProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecruiterProfile(
      uid: doc.id,
      name: data['name'] ?? 'Utilisateur',
      email: data['email'] ?? 'email@example.com',
      role: data['role'] ?? 'recruiter',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}