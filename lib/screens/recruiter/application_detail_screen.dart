import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../models/application.dart';
import '../../services/firestore_service.dart';
import '../../providers.dart';

class ApplicationDetailScreen extends ConsumerWidget {
  const ApplicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final jobId = args?['jobId'] as String?;
    final role = args?['role'] as String? ?? 'recruiter';

    // Vérification de l'authentification
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const SizedBox.shrink();
    }

    if (jobId == null) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: const Text(
            'Détails des candidatures',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: Text(
            'Erreur : ID de l\'offre manquant',
            style: TextStyle(color: AppColors.darkGrey),
          ),
        ),
      );
    }

    // Fetch the job to verify recruiter ownership
    final jobAsync = ref.watch(jobOfferProvider(jobId));
    final applicationsAsync = ref.watch(applicationsForJobProvider(jobId));

    return jobAsync.when(
      data: (job) {
        if (job == null ||
            (role == 'recruiter' && job.recruiterId != user.uid)) {
          return Scaffold(
            backgroundColor: AppColors.lightGrey,
            appBar: AppBar(
              backgroundColor: AppColors.primaryBlue,
              title: const Text(
                'Détails des candidatures',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: const Center(
              child: Text(
                'Accès refusé ou offre non trouvée',
                style: TextStyle(color: AppColors.darkGrey),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.lightGrey,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            title: const Text(
              'Détails des candidatures',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: applicationsAsync.when(
            data: (applications) {
              if (applications.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune candidature pour cette offre',
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    final isFavorite = ref
                        .watch(favoriteApplicationsProvider(user.uid))
                        .when(
                          data:
                              (favApps) => favApps.any(
                                (app) => app.id == application.id,
                              ),
                          loading: () => false,
                          error: (_, __) => false,
                        );

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Candidat: ${application.candidateId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Statut: ${application.status}',
                              style: const TextStyle(color: AppColors.darkGrey),
                            ),
                            Text(
                              'Date de candidature: ${DateFormat('dd/MM/yyyy').format(application.appliedAt)}',
                              style: const TextStyle(color: AppColors.darkGrey),
                            ),
                            Text(
                              'CV: ${application.cvUrl.isNotEmpty ? 'Disponible' : 'Non disponible'}',
                              style: const TextStyle(color: AppColors.darkGrey),
                            ),
                            if (application.cvUrl.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  // Logique pour ouvrir le CV
                                },
                                child: const Text(
                                  'Voir le CV',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
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
                                        !isFavorite
                                            ? 'Ajouté aux favoris'
                                            : 'Retiré des favoris',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e')),
                                  );
                                }
                              },
                              icon:
                                  isFavorite
                                      ? const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      )
                                      : const Icon(
                                        Icons.favorite_border,
                                        color: AppColors.darkGrey,
                                      ),
                              label: Text(
                                !isFavorite
                                    ? 'Ajouter aux favoris'
                                    : 'Retirer des favoris',
                                style: const TextStyle(color: AppColors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGrey,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stackTrace) => Center(
                  child: Text(
                    'Erreur lors du chargement: $error\nStackTrace: $stackTrace',
                    style: const TextStyle(color: AppColors.darkGrey),
                  ),
                ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Text(
              'Erreur lors du chargement de l\'offre: $error',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
          ),
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
                      (doc) => Application.fromFirestore(doc.data()!, doc.id),
                    )
                    .toList(),
          );
    });
