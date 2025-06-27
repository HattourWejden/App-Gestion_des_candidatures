import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../widgets/job_offer_card.dart';
import '../../services/auth_service.dart';
import '../../providers.dart';

class RecruiterDashboardScreen extends ConsumerWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const SizedBox.shrink();
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
              return const SizedBox.shrink();
            }
            final offersAsync = ref.watch(offersProvider(user.uid));

            return Scaffold(
              backgroundColor: AppColors.lightGrey,
              appBar: AppBar(
                backgroundColor: AppColors.primaryBlue,
                title: const Text(
                  'Tableau de bord - Recruteur',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed:
                        () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                ],
              ),
              body: offersAsync.when(
                data: (offers) {
                  print('Offers fetched: ${offers.length}'); // Debug log
                  offers.forEach(
                    (offer) => print('Offer: ${offer.toFirestore()}'),
                  ); // Debug log
                  if (offers.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune offre publiée',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return JobOfferCard(
                        offer: offer,
                        role: 'recruiter',
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.jobDetail,
                              arguments: {
                                'role': 'recruiter',
                                'offerId': offer.id,
                              },
                            ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) {
                  print('Offers error: $error'); // Debug log
                  return Center(child: Text('Erreur: $error'));
                },
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.primaryBlue,
                onPressed:
                    () => Navigator.pushNamed(context, AppRoutes.createoffer),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: AppColors.darkGrey,
                currentIndex: 0, // Default to Home
                onTap: (index) {
                  if (index == 1) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.applicationsManagement,
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
                    icon: Icon(Icons.list),
                    label: 'Candidatures',
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
