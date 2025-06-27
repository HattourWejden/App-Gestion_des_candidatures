import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  final String offerId;
  final String candidateId;
  final String status;
  final String cvUrl;
  final DateTime appliedAt;
  final String? name;
  final String? email;
  final String? phone;
  final String? education;
  final String? experience;
  final String? skills;
  final String? languages;
  final String? interests;
  final String? coverLetter;
  final String? recruiterId;

  Application({
    required this.id,
    required this.offerId,
    required this.candidateId,
    required this.status,
    required this.cvUrl,
    required this.appliedAt,
    this.name,
    this.email,
    this.phone,
    this.education,
    this.experience,
    this.skills,
    this.languages,
    this.interests,
    this.coverLetter,
    this.recruiterId,
  });

  factory Application.fromFirestore(Map<String, dynamic> data, String id) {
    return Application(
      id: id,
      offerId: data['jobId'] ?? '', // Align with FirestoreService
      candidateId: data['userId'] ?? '', // Align with FirestoreService
      status: data['status'] ?? 'pending', // Default to 'pending' if missing
      cvUrl: data['cvUrl'] ?? '',
      appliedAt:
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Use createdAt
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      education: data['education'],
      experience: data['experience'],
      skills: data['skills'],
      languages: data['languages'],
      interests: data['interests'],
      coverLetter: data['coverLetter'],
      recruiterId: data['recruiterId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'offerId': offerId,
      'candidateId': candidateId,
      'status': status,
      'cvUrl': cvUrl,
      'appliedAt': FieldValue.serverTimestamp(),
      'name': name,
      'email': email,
      'phone': phone,
      'education': education,
      'experience': experience,
      'skills': skills,
      'languages': languages,
      'interests': interests,
      'coverLetter': coverLetter,
      'recruiterId': recruiterId,
    };
  }
}
