import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../constants/app_routes.dart';

class UserProfile {
  final String? uid;
  final String? displayName;
  final String? email;
  final int? applicationCount; // Exemple de donnée supplémentaire

  UserProfile({this.uid, this.displayName, this.email, this.applicationCount});

  factory UserProfile.fromFirebaseUser(User user) {
    return UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'Nom',
      email: user.email ?? 'email@example.com',
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? 'Utilisateur',
      email: data['email'] ?? 'email@example.com',
      applicationCount: data['applicationCount'] ?? 0,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = _fetchUserProfile();
  }

  Future<UserProfile> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return UserProfile(
        displayName: 'Utilisateur',
        email: 'email@example.com',
      );
    }

    // Récupérer des données supplémentaires depuis Firestore si nécessaire
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return doc.exists
        ? UserProfile.fromFirestore(doc)
        : UserProfile.fromFirebaseUser(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur lors du chargement du profil'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Aucun profil disponible'));
          }

          final userProfile = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.lightGrey,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      userProfile.displayName ?? 'Utilisateur',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProfile.email ?? 'email@example.com',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildProfileItem(
                icon: Icons.work,
                title: 'Mes candidatures',
                subtitle: '${userProfile.applicationCount ?? 0} candidatures',
                onTap: () {
                  // Naviguer vers les candidatures
                },
              ),
              _buildProfileItem(
                icon: Icons.favorite,
                title: 'Offres favorites',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.favorites);
                },
              ),
              _buildProfileItem(
                icon: Icons.settings,
                title: 'Paramètres',
                onTap: () {
                  // Naviguer vers les paramètres
                },
              ),
              _buildProfileItem(
                icon: Icons.help,
                title: 'Aide & Support',
                onTap: () {
                  // Naviguer vers l'aide
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Déconnexion', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primaryBlue),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );
  }
}
