import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_offer.dart';
import '../models/application.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  // Toggle favorite status (for job offers or applications)
  Future<void> toggleFavorite(
    String userId,
    String itemId,
    bool isFavorite,
    String type,
  ) async {
    final favoriteRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('$type-$itemId');
    if (isFavorite) {
      await favoriteRef.set({
        'itemId': itemId,
        'type': type,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await favoriteRef.delete();
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

  // Upload CV to Firebase Storage
  Future<String?> uploadCV(String userId, PlatformFile file) async {
    try {
      final ref = _storage.ref().child(
        'cvs/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
      );
      final uploadTask = await ref.putData(file.bytes!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Apply to a job
  Future<void> applyToJob(
    String offerId,
    String candidateId,
    String cvUrl,
  ) async {
    final application = Application(
      id: '',
      offerId: offerId,
      candidateId: candidateId,
      status: 'pending',
      cvUrl: cvUrl,
      appliedAt: DateTime.now(),
    );
    await _firestore.collection('applications').add(application.toFirestore());
    // Increment application count
    await _firestore.collection('job_offers').doc(offerId).update({
      'applicationCount': FieldValue.increment(1),
    });
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
}

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
