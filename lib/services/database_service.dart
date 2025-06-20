import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addJob(Job job) async {
    try {
      await _firestore.collection('jobs').add({
        'title': job.title,
        'description': job.description,
        'status': job.status,
        'department': job.department,
        'application_count': job.applicationCount,
        'postedDate': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'offre: $e');
    }
  }

  Stream<List<Job>> getJobs({
    String? status,
    String? department,
    String? search,
  }) {
    try {
      Query query = _firestore
          .collection('jobs')
          .orderBy('postedDate', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (department != null) {
        query = query.where('department', isEqualTo: department);
      }
      if (search != null && search.isNotEmpty) {
        query = query
            .where('title', isGreaterThanOrEqualTo: search)
            .where('title', isLessThanOrEqualTo: search + '\uf8ff');
      }

      return query.snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Job(
                id: doc.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                status: data['status'] ?? 'open',
                department: data['department'] ?? 'Non spécifié',
                applicationCount: data['application_count'] ?? 0,
                postedDate: (data['postedDate'] as Timestamp?)?.toDate(),
              );
            }).toList(),
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des offres: $e');
    }
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
      // Note: Consider cleaning up applications sub-collection and userFavorites if needed
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'offre: $e');
    }
  }

  Stream<List<String>> getUserFavorites(String userId) {
    try {
      return _firestore
          .collection('userFavorites')
          .doc(userId)
          .snapshots()
          .map((doc) => doc.exists ? List<String>.from(doc['jobs'] ?? []) : []);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }

  Future<void> toggleFavorite(
    String userId,
    String jobId,
    bool isFavorite,
  ) async {
    try {
      final docRef = _firestore.collection('userFavorites').doc(userId);
      if (isFavorite) {
        await docRef.set({
          'jobs': FieldValue.arrayUnion([jobId]),
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          'jobs': FieldValue.arrayRemove([jobId]),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des favoris: $e');
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // New method to update application count
  Future<void> updateApplicationCount(String jobId, int newCount) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'application_count': newCount,
      });
    } catch (e) {
      throw Exception(
        'Erreur lors de la mise à jour du compteur de candidatures: $e',
      );
    }
  }
}
