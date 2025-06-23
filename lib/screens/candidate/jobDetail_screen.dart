import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../models/job_offer.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../providers.dart';

class CandidateJobDetailScreen extends ConsumerWidget {
  const CandidateJobDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
        if (jobId == null) {
          return const Scaffold(
            body: Center(child: Text('Erreur : Offre non trouvée')),
          );
        }
        final jobAsync = ref.watch(jobOfferProvider(jobId));

        return Scaffold(
          backgroundColor: AppColors.lightGrey,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            title: const Text(
              'Détails de l\'offre',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final favoritesAsync = ref.watch(
                    favoritesProvider({'userId': user.uid, 'type': 'job'}),
                  );
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
                            await ref
                                .read(firestoreServiceProvider)
                                .toggleFavorite(
                                  user.uid,
                                  jobId,
                                  !isFavorite,
                                  'job',
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
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        },
                      );
                    },
                    loading:
                        () => const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                    error:
                        (_, __) => const Icon(Icons.error, color: Colors.white),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Département: ${job.department}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Localisation: ${job.location}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type de contrat: ${job.contractType}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Salaire: ${job.salary}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Statut: ${job.status}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    job.status == 'open'
                                        ? AppColors.primaryGreen
                                        : AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Publié le: ${DateFormat('dd/MM/yyyy').format(job.createdAt)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.lightGrey),
                            const SizedBox(height: 16),
                            Text(
                              'Description',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              job.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null && result.files.isNotEmpty) {
                          try {
                            final cvUrl = await ref
                                .read(firestoreServiceProvider)
                                .uploadCV(user.uid, result.files.single);
                            if (cvUrl != null) {
                              await ref
                                  .read(firestoreServiceProvider)
                                  .applyToJob(jobId, user.uid, cvUrl);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Candidature envoyée avec succès',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur lors de l\'envoi de la candidature: $e',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Postuler'),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}
