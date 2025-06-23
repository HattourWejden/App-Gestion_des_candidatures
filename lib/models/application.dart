import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  final String offerId;
  final String candidateId;
  final String status;
  final String cvUrl;
  final DateTime appliedAt;

  Application({
    required this.id,
    required this.offerId,
    required this.candidateId,
    required this.status,
    required this.cvUrl,
    required this.appliedAt,
  });

  factory Application.fromFirestore(Map<String, dynamic> data, String id) {
    return Application(
      id: id,
      offerId: data['offerId'] ?? '',
      candidateId: data['candidateId'] ?? '',
      status: data['status'] ?? 'pending',
      cvUrl: data['cvUrl'] ?? '',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'offerId': offerId,
      'candidateId': candidateId,
      'status': status,
      'cvUrl': cvUrl,
      'appliedAt': FieldValue.serverTimestamp(),
    };
  }
}
