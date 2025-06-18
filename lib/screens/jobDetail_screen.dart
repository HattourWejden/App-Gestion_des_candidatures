
import 'package:candid_app/providers.dart';
import 'package:candid_app/screens/home_screen.dart';
import 'package:candid_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_routes.dart';
import '../constants/colors.dart';

import '../models/job.dart';

import '../services/database_service.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    return StreamBuilder(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const SizedBox.shrink();
        }

        final user = snapshot.data!;
        final Job? job = ModalRoute.of(context)?.settings.arguments as Job?;
        if (job == null) {
          return const Scaffold(
            body: Center(child: Text('Erreur : Offre non trouvée')),
          );
        }

        final applicationsAsync = ref.watch(applicationsProvider(job.id));

        return Scaffold(
          backgroundColor: AppColors.lightGrey,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            title: Text(
              job.title,
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final favoritesAsync = ref.watch(favoritesProvider(user.uid));
                  return favoritesAsync.when(
                    data: (favorites) {
                      final isFavorite = favorites.contains(job.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          try {
                            await DatabaseService().toggleFavorite(
                              user.uid,
                              job.id,
                              !isFavorite,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (_, __) => const Icon(Icons.error, color: Colors.white),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Département: ${job.department}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.darkGrey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Statut: ${job.status}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: job.status == 'open' ? AppColors.primaryGreen : AppColors.darkGrey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Candidatures: ${job.applicationCount}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.darkGrey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Publié le: ${job.postedDate != null ? DateFormat('dd/MM/yyyy').format(job.postedDate!) : 'Inconnu'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.darkGrey,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.lightGrey),
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.darkGrey,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestion de l\'offre',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: job.status,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.darkGrey),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'open', child: Text('Ouverte')),
                                  DropdownMenuItem(value: 'in_progress', child: Text('En cours')),
                                  DropdownMenuItem(value: 'closed', child: Text('Fermée')),
                                ],
                                onChanged: (value) async {
                                  if (value != null && value != job.status) {
                                    try {
                                      await DatabaseService().updateJobStatus(job.id, value);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Statut mis à jour')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmer la suppression'),
                                    content: const Text('Voulez-vous supprimer cette offre ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await DatabaseService().deleteJob(job.id);
                                    Navigator.pop(context); // Return to HomeScreen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Offre supprimée')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur: $e')),
                                    );
                                  }
                                }
                              },
                              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                    backgroundColor: WidgetStateProperty.all(Colors.red),
                                    foregroundColor: WidgetStateProperty.all(Colors.white),
                                  ),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Candidatures',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                        ),
                        const SizedBox(height: 8),
                        applicationsAsync.when(
                          data: (applications) {
                            if (applications.isEmpty) {
                              return const Text(
                                'Aucune candidature pour cette offre',
                                style: TextStyle(color: AppColors.darkGrey),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: applications.length,
                              separatorBuilder: (_, __) => const Divider(color: AppColors.lightGrey),
                              itemBuilder: (context, index) {
                                final application = applications[index];
                                return ListTile(
                                  title: Text(
                                    'Candidat: ${application.userId}',
                                    style: const TextStyle(color: AppColors.black),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Statut: ${application.status}',
                                        style: const TextStyle(color: AppColors.darkGrey),
                                      ),
                                      Text(
                                        'Date: ${application.appliedAt != null ? DateFormat('dd/MM/yyyy').format(application.appliedAt!) : 'Inconnu'}',
                                        style: const TextStyle(color: AppColors.darkGrey),
                                      ),
                                    ],
                                  ),
                                  // Placeholder for future candidate details navigation
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Détails du candidat à implémenter')),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text(
                            'Erreur lors du chargement des candidatures: $e',
                            style: const TextStyle(color: AppColors.darkGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}