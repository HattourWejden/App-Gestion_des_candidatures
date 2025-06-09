import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une offre d'emploi
  Future<void> addJob(Map<String, dynamic> jobData) async {
    await _firestore.collection('jobs').add(jobData);
  }

  // Récupérer toutes les offres
  Stream<QuerySnapshot> getJobs() {
    return _firestore.collection('jobs').orderBy('postedDate').snapshots();
  }

  // Récupérer les favoris d'un utilisateur
  Stream<DocumentSnapshot> getUserFavorites(String userId) {
    return _firestore.collection('userFavorites').doc(userId).snapshots();
  }

  // Ajouter/retirer des favoris
  Future<void> toggleFavorite(String userId, String jobId, bool isFavorite) async {
    if (isFavorite) {
      await _firestore.collection('userFavorites').doc(userId).update({
        'jobs': FieldValue.arrayUnion([jobId])
      });
    } else {
      await _firestore.collection('userFavorites').doc(userId).update({
        'jobs': FieldValue.arrayRemove([jobId])
      });
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).update(userData);
  }
}