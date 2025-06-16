import 'package:candid_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String status;
  final String department;
  final int applicationCount;
  final Timestamp postedDate;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.department,
    required this.applicationCount,
    required this.postedDate,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      department: data['department'] ?? '',
      applicationCount: data['application_count'] ?? 0,
      postedDate: data['postedDate'] ?? Timestamp.now(),
    );
  }
}

final jobsProvider = StreamProvider<List<Job>>((ref) {
  return DatabaseService().getJobs().map(
    (snapshot) => snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList(),
  );
});

final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final jobsSnapshot =
      await FirebaseFirestore.instance.collection('jobs').get();
  final applicationsSnapshot =
      await FirebaseFirestore.instance.collectionGroup('applications').get();
  return {
    'total_jobs': jobsSnapshot.docs.length,
    'active_jobs':
        jobsSnapshot.docs.where((doc) => doc['status'] == 'open').length,
    'total_applications': applicationsSnapshot.docs.length,
  };
});

final favoritesProvider = StreamProvider.family<List<String>, String>((
  ref,
  userId,
) {
  return DatabaseService().getUserFavorites(userId).map((snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return (data?['jobs'] as List<dynamic>?)?.cast<String>() ?? [];
  });
});

final filterProvider = StateProvider<Map<String, String?>>(
  (ref) => {'status': null, 'department': null, 'search': null},
);
