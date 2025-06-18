import 'package:candid_app/models/recruiterprofile.dart';

import 'package:candid_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/job.dart';
import '../models/application.dart';

final jobsProvider = StreamProvider<List<Job>>((ref) {
  final filters = ref.watch(filterProvider);
  return DatabaseService().getJobs(
    status: filters['status'],
    department: filters['department'],
    search: filters['search'],
  );
});

final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
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
  } catch (e) {
    print('Error loading stats: $e');
    return {'total_jobs': 0, 'active_jobs': 0, 'total_applications': 0};
  }
});

final favoritesProvider = StreamProvider.family<List<String>, String>((
  ref,
  userId,
) {
  return DatabaseService().getUserFavorites(userId);
});

final filterProvider = StateProvider<Map<String, String?>>(
  (ref) => {'status': null, 'department': null, 'search': null},
);

final applicationsProvider = StreamProvider.family<List<Application>, String>((
  ref,
  jobId,
) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .doc(jobId)
      .collection('applications')
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Application.fromFirestore(doc)).toList(),
      );
});

final favoriteJobsProvider = StreamProvider<List<Job>>((ref) {
  final userStream = ref.watch(authServiceProvider).user;
  return userStream.asyncExpand((user) {
    if (user == null) {
      return Stream.value([]);
    }
    final favoritesStream = DatabaseService().getUserFavorites(user.uid);
    return favoritesStream.asyncExpand((favoriteIds) {
      if (favoriteIds.isEmpty) {
        return Stream.value([]);
      }
      final ids =
          favoriteIds.length > 10 ? favoriteIds.sublist(0, 10) : favoriteIds;
      return FirebaseFirestore.instance
          .collection('jobs')
          .where(FieldPath.documentId, whereIn: ids)
          .orderBy('postedDate', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList(),
          );
    });
  });
});

final recruiterProfileProvider = StreamProvider<RecruiterProfile?>((ref) {
  final userStream = ref.watch(authServiceProvider).user;
  return userStream.asyncExpand((user) {
    if (user == null) {
      return Stream.value(null);
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? RecruiterProfile.fromFirestore(doc) : null);
  });
});


final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);