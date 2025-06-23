import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

class AuthService extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() : super(const AsyncValue.loading()) {
    _auth.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String role,
  ) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'role': role,
      });
    }
    return user;
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      rethrow;
    }
  }
}

final authServiceProvider =
    StateNotifierProvider<AuthService, AsyncValue<User?>>((ref) {
      return AuthService();
    });
