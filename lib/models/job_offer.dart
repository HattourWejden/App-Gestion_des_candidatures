import 'package:cloud_firestore/cloud_firestore.dart';

class JobOffer {
  final String id;
  final String title;
  final String description;
  final String location;
  final String contractType;
  final String salary;
  final String status;
  final String department;
  final String recruiterId;
  final int applicationCount;
  final DateTime createdAt;

  JobOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.contractType,
    required this.salary,
    required this.status,
    required this.department,
    required this.recruiterId,
    required this.applicationCount,
    required this.createdAt,
  });

  factory JobOffer.fromFirestore(Map<String, dynamic> data, String id) {
    return JobOffer(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      contractType: data['contractType'] ?? '',
      salary: data['salary'] ?? '',
      status: data['status'] ?? 'open',
      department: data['department'] ?? 'Non spécifié',
      recruiterId: data['recruiterId'] ?? '',
      applicationCount: data['applicationCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'contractType': contractType,
      'salary': salary,
      'status': status,
      'department': department,
      'recruiterId': recruiterId,
      'applicationCount': applicationCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
