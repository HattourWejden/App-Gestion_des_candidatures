import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

// In providers.dart
final openOffersProvider = StreamProvider<List<JobOffer>>((ref) {
  print('Fetching open offers'); // Debug log
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((snapshot) {
        final offers =
            snapshot.docs
                .map((doc) => JobOffer.fromFirestore(doc.data(), doc.id))
                .toList();
        print('Fetched ${offers.length} open offers'); // Debug log
        return offers;
      });
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
  return FirebaseFirestore.instance
      .collection('applications')
      .where('jobId', isEqualTo: jobId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => Application.fromFirestore(doc.data()!, doc.id))
                .toList(),
      );
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
  print('Récupération des offres favorites pour userId: $userId'); // Debug log
  return FirebaseFirestore.instance
      .collection('favorites')
      .where('userId', isEqualTo: userId)
      .where('type', isEqualTo: 'job')
      .snapshots()
      .asyncMap((snapshot) async {
        final jobIds =
            snapshot.docs.map((doc) => doc.data()['itemId'] as String).toList();
        print('IDs des offres favorites: $jobIds'); // Debug log
        final jobs = <JobOffer>[];
        for (final jobId in jobIds) {
          final jobDoc =
              await FirebaseFirestore.instance
                  .collection('jobs')
                  .doc(jobId)
                  .get();
          if (jobDoc.exists && jobDoc.data()!['status'] == 'open') {
            jobs.add(JobOffer.fromFirestore(jobDoc.data()!, jobDoc.id));
          }
        }
        print('Offres favorites chargées: ${jobs.length}'); // Debug log
        return jobs;
      });
});

final favoriteApplicationsProvider =
    StreamProvider.family<List<Application>, String>((ref, userId) {
      print('Fetching favorite applications for userId: $userId'); // Debug log
      return FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'application')
          .snapshots()
          .asyncMap((snapshot) async {
            final applicationIds =
                snapshot.docs
                    .map((doc) => doc.data()['itemId'] as String)
                    .toList();
            print('Favorite application IDs: $applicationIds'); // Debug log
            final applications = <Application>[];
            for (final appId in applicationIds) {
              final appDoc =
                  await FirebaseFirestore.instance
                      .collection('applications')
                      .doc(appId)
                      .get();
              if (appDoc.exists) {
                applications.add(
                  Application.fromFirestore(appDoc.data()!, appDoc.id),
                );
              }
            }
            print(
              'Loaded ${applications.length} favorite applications',
            ); // Debug log
            return applications;
          });
    });

final profileProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfile(userId);
});
