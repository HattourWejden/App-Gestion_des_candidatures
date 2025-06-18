import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:candid_app/providers.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref _ref;

  AuthService(this._ref);

  Stream<User?> get user => _auth.authStateChanges();

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _ref.read(databaseServiceProvider).updateUserProfile(user.uid, {
          'name': name,
          'email': email,
          'role': 'recruiter',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription : $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (!userDoc.exists || userDoc.data()?['role'] != 'recruiter') {
          await _ref.read(databaseServiceProvider).updateUserProfile(user.uid, {
            'name': userDoc.data()?['name'] ?? 'Recruiter',
            'email': email,
            'role': 'recruiter',
            'createdAt':
                userDoc.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion : $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

