import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Erreur d\'authentification: $e');
      rethrow;
    }
  }

  // Inscription avec email, mot de passe, nom et rôle
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = result.user;

      if (user != null) {
        // Enregistrer les informations de l'utilisateur dans Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email.trim(),
          'name': name.trim(),
          'role': role == UserRole.candidate ? 'candidate' : 'recruiter',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("Erreur d'inscription: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Erreur inattendue: $e");
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer le rôle de l'utilisateur
  Future<UserRole?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        String role = doc['role'];
        return role == 'candidate' ? UserRole.candidate : UserRole.recruiter;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du rôle: $e');
      return null;
    }
  }

  // Stream pour écouter les changements d'état d'authentification
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}