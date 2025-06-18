import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String status;
  final String department;
  final int applicationCount;
  final DateTime? postedDate;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.department,
    required this.applicationCount,
    this.postedDate,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'open',
      department: data['department'] ?? 'Non spécifié',
      applicationCount: data['application_count'] ?? 0,
      postedDate: (data['postedDate'] as Timestamp?)?.toDate(),
    );
  }
}