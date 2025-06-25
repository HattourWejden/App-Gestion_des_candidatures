import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/src/platform_file.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/job_offer.dart';
import '../models/application.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addJob(JobOffer job) async {
    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .add(job.toFirestore());
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'offre: $e');
      rethrow;
    }
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      print(
        'Mise à jour du statut pour jobId: $jobId, statut: $status',
      ); // Debug log
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'status': status,
      });
    } catch (e) {
      print('Erreur dans updateJobStatus: $e'); // Debug log
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      print('Suppression de jobId: $jobId'); // Debug log
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
    } catch (e) {
      print('Erreur dans deleteJob: $e'); // Debug log
      rethrow;
    }
  }

  // Get job offers for a recruiter
  Stream<List<JobOffer>> getJobOffers(String recruiterId) {
    return _firestore
        .collection('job_offers')
        .where('recruiterId', isEqualTo: recruiterId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => JobOffer.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get all open job offers
  Stream<List<JobOffer>> getOpenJobOffers() {
    return _firestore
        .collection('job_offers')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => JobOffer.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  Stream<JobOffer?> getJobOffer(String jobId) {
    return _firestore.collection('job_offers').doc(jobId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return null;
      return JobOffer.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  // Get applications for a job offer
  Stream<List<Application>> getApplications(String jobId) {
    return _firestore
        .collection('applications')
        .where('offerId', isEqualTo: jobId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Application.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> toggleFavorite(
    String userId,
    String itemId,
    bool isFavorited,
    String type,
  ) async {
    print(
      'Toggling favorite: userId=$userId, itemId=$itemId, isFavorited=$isFavorited, type=$type',
    ); // Debug log
    final favoriteRef = _firestore
        .collection('favorites')
        .doc('$userId-$itemId');
    try {
      if (isFavorited) {
        await favoriteRef.delete();
        print('Favorite deleted: $userId-$itemId'); // Debug log
      } else {
        await favoriteRef.set({
          'userId': userId,
          'itemId': itemId,
          'type': type,
          'createdAt': Timestamp.now(),
        });
        print('Favorite added: $userId-$itemId'); // Debug log
      }
    } catch (e, stack) {
      print('Error in toggleFavorite: $e, Stack: $stack'); // Debug log
      rethrow; // Ensure error is caught in UI
    }
  }

  // Get favorite item IDs for a user (job offers or applications)
  Stream<List<String>> getFavorites(String userId, String type) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .where('type', isEqualTo: type)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => doc.data()['itemId'] as String)
                  .toList(),
        );
  }

  // Get favorite job offers
  Stream<List<JobOffer>> getFavoriteJobs(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .where('type', isEqualTo: 'job')
        .snapshots()
        .asyncMap((snapshot) async {
          final jobIds =
              snapshot.docs
                  .map((doc) => doc.data()['itemId'] as String)
                  .toList();
          if (jobIds.isEmpty) return [];
          final jobsSnapshot =
              await _firestore
                  .collection('job_offers')
                  .where(FieldPath.documentId, whereIn: jobIds)
                  .get();
          return jobsSnapshot.docs
              .map((doc) => JobOffer.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get favorite applications
  Stream<List<Application>> getFavoriteApplications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .where('type', isEqualTo: 'application')
        .snapshots()
        .asyncMap((snapshot) async {
          final applicationIds =
              snapshot.docs
                  .map((doc) => doc.data()['itemId'] as String)
                  .toList();
          if (applicationIds.isEmpty) return [];
          final applicationsSnapshot =
              await _firestore
                  .collection('applications')
                  .where(FieldPath.documentId, whereIn: applicationIds)
                  .get();
          return applicationsSnapshot.docs
              .map((doc) => Application.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get user profile
  Stream<UserModel?> getUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  // Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  Future<void> applyToJob(
    String jobId,
    String userId,
    String? cvUrl, {
    Map<String, dynamic>? additionalData,
  }) async {
    if (jobId.isEmpty || userId.isEmpty) {
      throw Exception('Invalid input: jobId or userId is empty');
    }

    final applicationData = {
      'jobId': jobId,
      'userId': userId,
      'createdAt': DateTime.now(),
      if (cvUrl != null) 'cvUrl': cvUrl,
      ...?additionalData,
    };

    await _firestore.collection('applications').add(applicationData);
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ??
            'candidate'; // Par défaut, rôle 'candidate'
      }
      throw Exception('Utilisateur non trouvé');
    } catch (e) {
      print('Erreur lors de la récupération du rôle: $e');
      rethrow;
    }
  }

  Future uploadCV(String userId, PlatformFile platformFile) async {}
}

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
