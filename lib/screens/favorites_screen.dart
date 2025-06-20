import 'package:candid_app/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_routes.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _currentIndex = 1; // Favorites tab

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    return StreamBuilder(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final user = snapshot.data!;
        final favoriteJobsAsync = ref.watch(favoriteJobsProvider);

        return Scaffold(
          backgroundColor: AppColors.lightGrey,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            title: const Text(
              'Mes Favoris',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await authService.signOut();
                },
              ),
            ],
          ),
          body: favoriteJobsAsync.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune offre favorite',
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        job.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.darkGrey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Statut: ${job.status}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.darkGrey),
                          ),
                          Text(
                            'Département: ${job.department}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.darkGrey),
                          ),
                          Text(
                            'Candidatures: ${job.applicationCount}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.darkGrey),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.star,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: () async {
                          try {
                            await DatabaseService().toggleFavorite(
                              user.uid,
                              job.id,
                              false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Retiré des favoris'),
                              ),
                            );
                          } on FirebaseException catch (e) {
                            String errorMessage =
                                'Erreur lors de la mise à jour des favoris';
                            if (e.code == 'unavailable') {
                              errorMessage = 'Vérifiez votre connexion réseau';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur inattendue: $e')),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.jobDetail,
                          arguments: job,
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading:
                () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
            error:
                (error, _) => Center(
                  child: Text(
                    'Erreur lors du chargement des favoris: $error',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
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
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              } else if (index == 2) {
                Navigator.pushNamed(context, AppRoutes.profile);
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoris'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
