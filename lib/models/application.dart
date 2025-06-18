import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Application {
  final String id;
  final String userId;
  final DateTime? appliedAt;
  final String status;

  Application({
    required this.id,
    required this.userId,
    this.appliedAt,
    required this.status,
  });

  factory Application.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Application(
      id: doc.id,
      userId: data['userId'] ?? '',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
    );
  }
}
