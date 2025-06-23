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
            if (roleSnapshot.data != 'candidate') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              });
              return const Scaffold(body: SizedBox.shrink());
            }
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
                      return JobOfferCard(
                        offer: job,
                        role: 'candidate',
                        showFavoriteButton: true,
                        userId: user.uid,
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.jobDetail,
                              arguments: {
                                'role': 'candidate',
                                'offerId': job.id,
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
                      arguments: {'role': 'candidate'},
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
