import 'package:candid_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/application_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _currentIndex = 1; // Favorites tab

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final role = args?['role'] as String? ?? 'recruiter';
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
            if (roleSnapshot.data != 'recruiter') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              });
              return const Scaffold(body: SizedBox.shrink());
            }
            final favoriteApplicationsAsync = ref.watch(
              favoriteApplicationsProvider(user.uid),
            );

            return Scaffold(
              backgroundColor: AppColors.lightGrey,
              appBar: AppBar(
                backgroundColor: AppColors.primaryBlue,
                title: const Text(
                  'Mes Candidatures Favorites',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: favoriteApplicationsAsync.when(
                data: (applications) {
                  if (applications.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune candidature favorite',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final application = applications[index];
                      return ApplicationCard(
                        application: application,
                        role: 'recruiter',
                        showFavoriteButton: true,
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
                        'Erreur lors du chargement des candidatures favorites: $error',
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
                      arguments: {'role': 'recruiter'},
                    );
                  } else if (index == 2) {
                    Navigator.pushNamed(context, AppRoutes.profile);
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
}
