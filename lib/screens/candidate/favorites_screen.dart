import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/job_offer_card.dart';
import '../../providers.dart';

class CandidateFavoritesScreen extends ConsumerStatefulWidget {
  const CandidateFavoritesScreen({super.key});

  @override
  ConsumerState<CandidateFavoritesScreen> createState() =>
      _CandidateFavoritesScreenState();
}

class _CandidateFavoritesScreenState
    extends ConsumerState<CandidateFavoritesScreen> {
  int _currentIndex = 1; // Favorites tab

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          print(
            'Utilisateur non connecté, redirection vers login',
          ); // Debug log
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        print('Utilisateur connecté: ${user.uid}'); // Debug log
        return FutureBuilder<String?>(
          future: ref.read(authServiceProvider.notifier).getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (roleSnapshot.hasError) {
              print(
                'Erreur lors de la récupération du rôle: ${roleSnapshot.error}',
              ); // Debug log
            }
            if (roleSnapshot.data != 'candidate') {
              print(
                'Rôle non candidat: ${roleSnapshot.data}, redirection vers welcome',
              ); // Debug log
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              });
              return const Scaffold(body: SizedBox.shrink());
            }
            print('Rôle valide: ${roleSnapshot.data}'); // Debug log
            final favoriteJobsAsync = ref.watch(favoriteJobsProvider(user.uid));

            return Scaffold(
              backgroundColor: AppColors.lightGrey,
              appBar: AppBar(
                backgroundColor: AppColors.primaryBlue,
                title: const Text(
                  'Mes Favoris',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: favoriteJobsAsync.when(
                data: (jobs) {
                  print(
                    'Offres favorites chargées: ${jobs.length}',
                  ); // Debug log
                  if (jobs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune offre favorite',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      print(
                        'Affichage de l\'offre favorite: ${job.title}, ID: ${job.id}',
                      ); // Debug log
                      return JobOfferCard(
                        offer: job,
                        role: 'candidate',
                        showFavoriteButton: true,
                        userId: user.uid,
                        onTap: () {
                          print(
                            'Navigation vers jobDetail pour offerId: ${job.id}',
                          ); // Debug log
                          Navigator.pushNamed(
                            context,
                            AppRoutes.jobDetail,
                            arguments: {'role': 'candidate', 'offerId': job.id},
                          );
                        },
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
                error: (error, _) {
                  print(
                    'Erreur dans favoriteJobsProvider: $error',
                  ); // Debug log
                  return Center(
                    child: Text(
                      'Erreur lors du chargement des favoris: $error',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  );
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: AppColors.darkGrey,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  if (index == 0) {
                    print('Navigation vers home (candidate)'); // Debug log
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                      arguments: {'role': 'candidate'},
                    );
                  } else if (index == 2) {
                    print('Navigation vers profile'); // Debug log
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
      error: (e, _) {
        print('Erreur dans authServiceProvider: $e'); // Debug log
        return Scaffold(body: Center(child: Text('Erreur: $e')));
      },
    );
  }
}
