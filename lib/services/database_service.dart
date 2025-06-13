import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addJob(Map<String, dynamic> jobData) async {
    await _firestore.collection('jobs').add({
      ...jobData,
      'postedDate': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getJobs() {
    return _firestore.collection('jobs').orderBy('postedDate', descending: true).snapshots();
  }

  Stream<DocumentSnapshot> getUserFavorites(String userId) {
    return _firestore.collection('userFavorites').doc(userId).snapshots();
  }

  Future<void> toggleFavorite(String userId, String jobId, bool isFavorite) async {
    final docRef = _firestore.collection('userFavorites').doc(userId);
    if (isFavorite) {
      await docRef.set({
        'jobs': FieldValue.arrayUnion([jobId])
      }, SetOptions(merge: true));
    } else {
      await docRef.set({
        'jobs': FieldValue.arrayRemove([jobId])
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
  }

  Future<void> applyToJob(String userId, String jobId) async {
    final applicationData = {
      'userId': userId,
      'jobId': jobId,
      'appliedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    };
    await _firestore
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .add(applicationData);
    await _firestore.collection('jobs').doc(jobId).update({
      'application_count': FieldValue.increment(1),
    });
  }
}