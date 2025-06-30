import 'package:candid_app/services/firestore_service.dart';
import 'package:candid_app/widgets/application_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const SizedBox.shrink();
    }

    final favoritesAsync = ref.watch(favoriteApplicationsProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Favoris', style: TextStyle(color: Colors.white)),
      ),
      body: favoritesAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(
              child: Text(
                'Aucune candidature favorite',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              print('Building Favorite ApplicationCard for index: $index');
              final application = applications[index];
              return Consumer(
                builder: (context, ref, _) {
                  final isFavoriteAsync = ref.watch(
                    favoriteApplicationsProvider(user.uid),
                  );
                  return isFavoriteAsync.when(
                    data: (favApps) {
                      final isFavorite = favApps.any(
                        (app) => app.id == application.id,
                      );
                      return ApplicationCard(
                        application: application,
                        showFavoriteButton: true,
                        role: 'recruiter',
                        isFavorite:
                            isFavorite, // Pass the computed isFavorite state
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.applicationDetail,
                            arguments: {
                              'role': 'recruiter',
                              'applicationId': application.id,
                            },
                          );
                        },
                        onFavoriteToggle: () async {
                          try {
                            print(
                              'Toggling favorite for application: ${application.id}, user: ${user.uid}, current state: $isFavorite',
                            );
                            await ref
                                .read(firestoreServiceProvider)
                                .toggleFavorite(
                                  user.uid,
                                  application.id,
                                  isFavorite,
                                  'application',
                                );
                            ref.invalidate(
                              favoriteApplicationsProvider(user.uid),
                            );
                            print('Favorite toggled successfully');
                            // Refresh the screen to reflect the change
                            ref.refresh(favoriteApplicationsProvider(user.uid));
                          } catch (e, stack) {
                            print('Error toggling favorite: $e, Stack: $stack');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        },
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) {
                      print(
                        'Error in favoriteApplicationsProvider: $error, Stack: $stack',
                      );
                      return Center(
                        child: Text(
                          'Erreur: $error',
                          style: const TextStyle(color: AppColors.darkGrey),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('Error loading favorites: $error, Stack: $stack');
          return Center(
            child: Text(
              'Erreur: $error',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.darkGrey,
        currentIndex: 1, // Favorites tab
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.applicationsManagement,
              arguments: {'role': 'recruiter'},
            );
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Candidatures',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
