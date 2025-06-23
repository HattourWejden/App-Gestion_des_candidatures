import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_offer.dart';
import '../models/application.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

final offersProvider = StreamProvider.family<List<JobOffer>, String>((
  ref,
  recruiterId,
) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('recruiterId', isEqualTo: recruiterId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => JobOffer.fromFirestore(doc.data(), doc.id))
                .toList(),
      );
});

final openOffersProvider = StreamProvider<List<JobOffer>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getOpenJobOffers();
});

final jobOfferProvider = StreamProvider.family<JobOffer?, String>((ref, jobId) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .doc(jobId)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          return JobOffer.fromFirestore(snapshot.data()!, snapshot.id);
        }
        return null;
      });
});

final applicationsProvider = StreamProvider.family<List<Application>, String>((
  ref,
  jobId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getApplications(jobId);
});

final favoritesProvider =
    StreamProvider.family<List<String>, Map<String, String>>((ref, params) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getFavorites(params['userId']!, params['type']!);
    });

final favoriteJobsProvider = StreamProvider.family<List<JobOffer>, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getFavoriteJobs(userId);
});

final favoriteApplicationsProvider =
    StreamProvider.family<List<Application>, String>((ref, userId) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getFavoriteApplications(userId);
    });

final profileProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfile(userId);
});
