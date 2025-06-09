import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView(
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
          const Center(
            child: Column(
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(
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
                  Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primaryBlue),
          title: Text(title),
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
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
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