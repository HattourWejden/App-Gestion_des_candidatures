import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../providers.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final jobId = args?['offerId'] as String?;
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
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (roleSnapshot.data != 'recruiter') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              });
              return const SizedBox.shrink();
            }
            if (jobId == null) {
              return const Scaffold(body: Center(child: Text('Erreur : Offre non trouvée')));
            }
            final jobAsync = ref.watch(jobOfferProvider(jobId));

            return Scaffold(
              backgroundColor: AppColors.lightGrey,
              appBar: AppBar(
                backgroundColor: AppColors.primaryBlue,
                title: const Text('Détails de l\'offre', style: TextStyle(color: Colors.white)),
                actions: [
                  Consumer(
                    builder: (context, ref, _) {
                      final favoritesAsync = ref.watch(favoritesProvider({'userId': user.uid, 'type': 'job'}));
                      return favoritesAsync.when(
                        data: (favorites) {
                          final isFavorite = favorites.contains(jobId);
                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.star : Icons.star_border,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              try {
                                await ref.read(firestoreServiceProvider).toggleFavorite(
                                      user.uid,
                                      jobId,
                                      !isFavorite,
                                      'job',
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris'),
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
              body: jobAsync.when(
                data: (job) {
                  if (job == null) {
                    return const Center(child: Text('Erreur : Offre non trouvée'));
                  }
                  return Padding(
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Localisation: ${job.location}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Type de contrat: ${job.contractType}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Salaire: ${job.salary}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Publié le: ${DateFormat('dd/MM/yyyy').format(job.createdAt)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
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
                                              await ref.read(firestoreServiceProvider).updateJobStatus(job.id, value);
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
                                            await ref.read(firestoreServiceProvider).deleteJob(job.id);
                                            Navigator.pop(context);
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                Consumer(
                                  builder: (context, ref, _) {
                                    final applicationsAsync = ref.watch(applicationsProvider(job.id));
                                    return applicationsAsync.when(
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
                                                'Candidat: ${application.candidateId}',
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
                                                    'Date: ${DateFormat('dd/MM/yyyy').format(application.appliedAt)}',
                                                    style: const TextStyle(color: AppColors.darkGrey),
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.applicationDetail,
                                                  arguments: {'applicationId': application.id},
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
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            );
          },
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }
}