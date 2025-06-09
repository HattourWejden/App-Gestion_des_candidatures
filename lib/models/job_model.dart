import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final List<String> requirements;
  final bool isFavorite;
  final DateTime postedDate;
  final bool isActive; // Ajouté

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.requirements,
    this.isFavorite = false,
    required this.postedDate,
    required this.isActive, // Ajouté
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      postedDate: (map['postedDate'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true, // Ajouté
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'requirements': requirements,
      'isFavorite': isFavorite,
      'postedDate': Timestamp.fromDate(postedDate),
      'isActive': isActive, // Ajouté
    };
  }
}