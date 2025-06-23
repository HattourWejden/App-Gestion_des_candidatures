import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_offer.dart';
import '../models/application.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

final offersProvider = StreamProvider.family<List<JobOffer>, String>((
  ref,
  recruiterId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getJobOffers(recruiterId);
});

final openOffersProvider = StreamProvider<List<JobOffer>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getOpenJobOffers();
});

final jobOfferProvider = StreamProvider.family<JobOffer?, String>((ref, jobId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getJobOffer(jobId);
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
