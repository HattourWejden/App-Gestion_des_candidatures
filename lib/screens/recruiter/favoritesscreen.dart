import 'package:candid_app/models/application.dart';
import 'package:candid_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../providers.dart';
import 'applicationsmanagementscreen.dart'; // Import to reuse ApplicationCard

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
        title: Text(
          'Favoris',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: favoritesAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: AppColors.darkGrey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune candidature favorite',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des candidatures aux favoris',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AppColors.darkGrey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
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
                    isFavorite: isFavorite,
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
                        await ref
                            .read(firestoreServiceProvider)
                            .toggleFavorite(
                              user.uid,
                              application.id,
                              isFavorite,
                              'application',
                            );
                        ref.invalidate(favoriteApplicationsProvider(user.uid));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite
                                  ? 'Retiré des favoris'
                                  : 'Ajouté aux favoris',
                            ),
                            backgroundColor:
                                isFavorite
                                    ? Colors.red
                                    : AppColors.primaryGreen,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Text(
                        'Erreur: $error',
                        style: GoogleFonts.roboto(color: AppColors.darkGrey),
                      ),
                    ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Text(
                'Erreur: $error',
                style: GoogleFonts.roboto(color: AppColors.darkGrey),
              ),
            ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.darkGrey,
        currentIndex: 1,
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Candidatures',
            tooltip: 'Voir toutes les candidatures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favoris',
            tooltip: 'Voir les favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
            tooltip: 'Voir le profil',
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.roboto(),
      ),
    );
  }
}
