import 'package:candid_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _currentIndex = 2; // Profile tab

  void _editName(BuildContext context, String currentName, String uid) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier le nom'),
            content: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Entrez votre nom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez entrer un nom')),
                    );
                    return;
                  }
                  try {
                    await ref.read(firestoreServiceProvider).updateUserProfile(
                      uid,
                      {'name': nameController.text.trim()},
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nom mis à jour')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  try {
                    await ref.read(authServiceProvider.notifier).signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la déconnexion: $e'),
                      ),
                    );
                  }
                },
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return FutureBuilder<String?>(
          future: ref.read(authServiceProvider.notifier).getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final role = roleSnapshot.data ?? 'candidate';
            final profileAsync = ref.watch(profileProvider(user.uid));

            return Scaffold(
              backgroundColor: AppColors.lightGrey,
              appBar: AppBar(
                backgroundColor: AppColors.primaryBlue,
                title: const Text(
                  'Mon Profil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return const Center(
                      child: Text(
                        'Profil non trouvé',
                        style: TextStyle(color: AppColors.darkGrey),
                      ),
                    );
                  }
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
                              child: GestureDetector(
                                onTap:
                                    () => _editName(
                                      context,
                                      profile.name,
                                      user.uid,
                                    ),
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              profile.name,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rôle: ${role == 'recruiter' ? 'Recruteur' : 'Candidat'}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                            if (profile.createdAt != null)
                              Text(
                                'Inscrit le: ${DateFormat('dd/MM/yyyy').format(profile.createdAt!)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.darkGrey),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (role == 'recruiter') ...[
                        _buildProfileItem(
                          icon: Icons.work,
                          title: 'Mes offres',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.home,
                              arguments: {'role': 'recruiter'},
                            );
                          },
                        ),
                        _buildProfileItem(
                          icon: Icons.star,
                          title: 'Offres favorites',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.favorites,
                              arguments: {'role': 'recruiter'},
                            );
                          },
                        ),
                      ] else ...[
                        _buildProfileItem(
                          icon: Icons.description,
                          title: 'Mes candidatures',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité à implémenter'),
                              ),
                            );
                          },
                        ),
                        _buildProfileItem(
                          icon: Icons.star,
                          title: 'Offres favorites',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.favorites,
                              arguments: {'role': 'candidate'},
                            );
                          },
                        ),
                        _buildProfileItem(
                          icon: Icons.upload_file,
                          title: 'Télécharger CV',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité à implémenter'),
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _showLogoutDialog(context),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Déconnexion',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading:
                    () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                error:
                    (e, _) => Center(
                      child: Text(
                        'Erreur lors du chargement du profil: $e',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: AppColors.darkGrey,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  if (index == 0) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                      arguments: {'role': role},
                    );
                  } else if (index == 1) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.favorites,
                      arguments: {'role': role},
                    );
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.star),
                    label: 'Favoris',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            );
          },
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
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
          title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          trailing: const Icon(Icons.chevron_right, color: AppColors.darkGrey),
          onTap: onTap,
        ),
        const Divider(height: 1, color: AppColors.lightGrey),
      ],
    );
  }
}
