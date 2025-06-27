import 'package:candid_app/screens/candidate/ApplicationFormDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../models/application.dart';
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
    print('Job ID reçu: $jobId'); // Debug log

    final authState = ref.watch(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          print('Utilisateur non connecté, redirection vers login');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const SizedBox.shrink();
        }
        print('Utilisateur connecté: ${user.uid}');
        if (jobId == null) {
          print('Job ID null, affichage erreur');
          return const Scaffold(
            body: Center(child: Text('Erreur : Offre non trouvée')),
          );
        }
        final jobAsync = ref.watch(jobOfferProvider(jobId));
        final applicationsAsync = ref.watch(applicationsForJobProvider(jobId));

        return jobAsync.when(
          data: (job) {
            if (job == null) {
              print('Offre null pour jobId: $jobId');
              return const Center(child: Text('Erreur : Offre non trouvée'));
            }
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
                          print(
                            'Favoris chargés, isFavorite: $isFavorite pour jobId: $jobId',
                          );
                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.star : Icons.star_border,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              try {
                                print('Toggling favori pour jobId: $jobId');
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
                                print('Erreur lors du toggle favori: $e');
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
                        error: (e, _) {
                          print('Erreur dans favoritesProvider: $e');
                          return const Icon(Icons.error, color: Colors.white);
                        },
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
                    // Afficher le bouton "Postuler" uniquement pour les candidats
                    if (user.uid != null &&
                        (ref
                                    .watch(profileProvider(user.uid))
                                    .valueOrNull
                                    ?.role ??
                                'candidate') ==
                            'candidate')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            print('Bouton Postuler cliqué pour jobId: $jobId');
                            showDialog(
                              context: context,
                              builder:
                                  (context) => ApplicationFormDialog(
                                    jobId: jobId ?? '',
                                    userId: user.uid,
                                    ref: ref,
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Postuler'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            print('Erreur dans jobOfferProvider: $e');
            return Center(child: Text('Erreur: $e'));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        print('Erreur dans authServiceProvider: $e');
        return Center(child: Text('Erreur: $e'));
      },
    );
  }
}

// Updated provider to ensure recruiter ownership
final applicationsForJobProvider =
    StreamProvider.family<List<Application>, String>((ref, jobId) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Stream.empty();
      return FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map(
                      (doc) => Application.fromFirestore(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList(),
          )
          .handleError((error, stack) {
            print('Erreur dans applicationsForJobProvider: $error');
            return [];
          });
    });
