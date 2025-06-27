import 'package:candid_app/models/application.dart';
import 'package:candid_app/services/auth_service.dart';
import 'package:candid_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../providers.dart';

class ApplicationsManagementScreen extends ConsumerWidget {
  const ApplicationsManagementScreen({super.key});

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

            final applicationsAsync = ref.watch(allApplicationsProvider);

            return applicationsAsync.when(
              data: (applications) {
                return Scaffold(
                  backgroundColor: AppColors.lightGrey,
                  appBar: AppBar(
                    backgroundColor: AppColors.primaryBlue,
                    title: const Text(
                      'Gestion des Candidatures',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  body: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final application = applications[index];
                      final isFavoriteAsync = ref.watch(
                        favoriteApplicationsProvider(user.uid),
                      );

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          title: Text(
                            'Candidat: ${application.candidateId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Statut: ${application.status}',
                            style: const TextStyle(color: AppColors.darkGrey),
                          ),
                          trailing: isFavoriteAsync.when(
                            data: (favApps) {
                              final isFavorite = favApps.any(
                                (app) => app.id == application.id,
                              );
                              return IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isFavorite
                                          ? Colors.red
                                          : AppColors.darkGrey,
                                ),
                                onPressed: () async {
                                  await ref
                                      .read(firestoreServiceProvider)
                                      .toggleFavorite(
                                        user.uid,
                                        application.id,
                                        !isFavorite,
                                        'application',
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFavorite
                                            ? 'Retiré des favoris'
                                            : 'Ajouté aux favoris',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading:
                                () => const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            error: (_, __) => const Icon(Icons.error),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${DateFormat('dd/MM/yyyy').format(application.appliedAt)}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'CV URL: ${application.cvUrl ?? 'Non disponible'}',
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            () => _showApplicationDetails(
                                              context,
                                              application,
                                            ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Voir détails'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final newStatus =
                                              await _showStatusDialog(
                                                context,
                                                application.status,
                                              );
                                          if (newStatus != null &&
                                              newStatus != application.status) {
                                            await ref
                                                .read(firestoreServiceProvider)
                                                .updateApplicationStatus(
                                                  application.id,
                                                  newStatus,
                                                );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Statut mis à jour',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryGreen,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Modifier statut'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final confirm = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirmer la suppression',
                                                  ),
                                                  content: const Text(
                                                    'Voulez-vous supprimer cette candidature ?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Annuler',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Supprimer',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                          if (confirm == true) {
                                            await ref
                                                .read(firestoreServiceProvider)
                                                .deleteApplication(
                                                  application.id,
                                                );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Candidature supprimée',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    selectedItemColor: AppColors.primaryBlue,
                    unselectedItemColor: AppColors.darkGrey,
                    currentIndex: 0,
                    onTap: (index) {
                      if (index == 1) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.favorites,
                          arguments: {'role': 'recruiter'},
                        );
                      } else if (index == 2) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.profile,
                        );
                      }
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.assignment),
                        label: 'Candidatures',
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
              loading:
                  () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, _) => Scaffold(
                    body: Center(
                      child: Text(
                        'Erreur lors du chargement des candidatures: $error',
                        style: TextStyle(color: AppColors.darkGrey),
                      ),
                    ),
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

  // Affiche les détails de la candidature
  void _showApplicationDetails(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Détails de la candidature'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Candidat: ${application.candidateId}'),
                  Text('Statut: ${application.status}'),
                  Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(application.appliedAt)}',
                  ),
                  if (application.cvUrl != null)
                    Text('CV URL: ${application.cvUrl}'),
                  if (application.name != null)
                    Text('Nom: ${application.name}'),
                  if (application.email != null)
                    Text('Email: ${application.email}'),
                  if (application.phone != null)
                    Text('Téléphone: ${application.phone}'),
                  if (application.education != null)
                    Text('Éducation: ${application.education}'),
                  if (application.experience != null)
                    Text('Expérience: ${application.experience}'),
                  if (application.skills != null)
                    Text('Compétences: ${application.skills}'),
                  if (application.languages != null)
                    Text('Langues: ${application.languages}'),
                  if (application.interests != null)
                    Text('Intérêts: ${application.interests}'),
                  if (application.coverLetter != null)
                    Text('Lettre de motivation: ${application.coverLetter}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  // Affiche le dialog de sélection de statut
  Future<String?> _showStatusDialog(
    BuildContext context,
    String currentStatus,
  ) async {
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier le statut'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('En attente'),
                  selected: currentStatus == 'pending',
                  onTap: () => Navigator.pop(context, 'pending'),
                ),
                ListTile(
                  title: const Text('En cours'),
                  selected: currentStatus == 'in_progress',
                  onTap: () => Navigator.pop(context, 'in_progress'),
                ),
                ListTile(
                  title: const Text('Acceptée'),
                  selected: currentStatus == 'accepted',
                  onTap: () => Navigator.pop(context, 'accepted'),
                ),
                ListTile(
                  title: const Text('Rejetée'),
                  selected: currentStatus == 'rejected',
                  onTap: () => Navigator.pop(context, 'rejected'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ],
          ),
    );
  }
}
