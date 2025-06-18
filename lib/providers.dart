import 'package:candid_app/models/recruiterprofile.dart';
import 'package:candid_app/screens/home_screen.dart';
import 'package:candid_app/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

import '../models/job.dart';
import '../models/application.dart';


final jobsProvider = StreamProvider<List<Job>>((ref) {
  return DatabaseService().getJobs();
});

final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final jobsSnapshot = await FirebaseFirestore.instance.collection('jobs').get();
  final applicationsSnapshot =
      await FirebaseFirestore.instance.collectionGroup('applications').get();
  return {
    'total_jobs': jobsSnapshot.docs.length,
    'active_jobs': jobsSnapshot.docs.where((doc) => doc['status'] == 'open').length,
    'total_applications': applicationsSnapshot.docs.length,
  };
});

final favoritesProvider = StreamProvider.family<List<String>, String>((ref, userId) {
  return DatabaseService().getUserFavorites(userId);
});

final filterProvider = StateProvider<Map<String, String?>>(
  (ref) => {'status': null, 'department': null, 'search': null},
);

final applicationsProvider = StreamProvider.family<List<Application>, String>((ref, jobId) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .doc(jobId)
      .collection('applications')
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Application.fromFirestore(doc)).toList());
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
      // Firestore whereIn supports up to 10 IDs
      final ids = favoriteIds.length > 10 ? favoriteIds.sublist(0, 10) : favoriteIds;
      return FirebaseFirestore.instance
          .collection('jobs')
          .where(FieldPath.documentId, whereIn: ids)
          .orderBy('postedDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList());
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
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);