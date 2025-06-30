import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

final openOffersProvider = StreamProvider<List<JobOffer>>((ref) {
  print('Fetching open offers');
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((snapshot) {
        final offers =
            snapshot.docs
                .map((doc) => JobOffer.fromFirestore(doc.data(), doc.id))
                .toList();
        print('Fetched ${offers.length} open offers');
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
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getFavoriteJobs(userId);
});

final favoriteApplicationsProvider = StreamProvider.family<
  List<Application>,
  String
>((ref, userId) {
  print('Fetching favorite applications for userId: $userId');
  return FirebaseFirestore.instance
      .collection('favorites')
      .where('userId', isEqualTo: userId)
      .where('type', isEqualTo: 'application')
      .snapshots()
      .asyncMap((snapshot) async {
        final applications = <Application>[];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final applicationId = data['itemId'] as String?;
          if (applicationId != null) {
            try {
              final applicationDoc =
                  await FirebaseFirestore.instance
                      .collection('applications')
                      .doc(applicationId)
                      .get();
              if (applicationDoc.exists) {
                applications.add(
                  Application.fromFirestore(
                    applicationDoc.data()!,
                    applicationDoc.id,
                  ),
                );
              } else {
                print('Application not found: $applicationId');
              }
            } catch (e, stack) {
              print(
                'Error fetching application $applicationId: $e, Stack: $stack',
              );
            }
          } else {
            print('Invalid itemId in favorite: $data');
          }
        }
        print(
          'Fetched ${applications.length} favorite applications for user: $userId',
        );
        return applications;
      })
      .handleError((error, stack) {
        print('Error in favoriteApplicationsProvider: $error, Stack: $stack');
        return <Application>[];
      });
});



final profileProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfile(userId);
});
