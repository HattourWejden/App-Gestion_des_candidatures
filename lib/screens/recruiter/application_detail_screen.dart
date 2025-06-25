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
    final applicationId = args?['applicationId'] as String?;
    final role = args?['role'] as String? ?? 'recruiter';

    if (applicationId == null) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          title: const Text(
            'Détails de la candidature',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: Text(
            'Erreur : ID de candidature manquant',
            style: TextStyle(color: AppColors.darkGrey),
          ),
        ),
      );
    }

    // Fetch the specific application
    final applicationAsync = ref.watch(applicationProvider(applicationId));

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Détails de la candidature',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: applicationAsync.when(
        data: (application) {
          if (application == null) {
            return const Center(
              child: Text(
                'Candidature non trouvée',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
              ),
            );
          }

          // Check if the application is favorited
          final isFavorite = ref
              .watch(
                favoriteApplicationsProvider(
                  FirebaseAuth.instance.currentUser!.uid,
                ),
              )
              .when(
                data:
                    (applications) =>
                        applications.any((app) => app.id == application.id),
                loading: () => false,
                error: (_, __) => false,
              );

          return Padding(
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
                      // Implement CV viewing logic (e.g., open URL)
                    },
                    child: const Text(
                      'Voir le CV',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(firestoreServiceProvider)
                          .toggleFavorite(
                            FirebaseAuth.instance.currentUser!.uid,
                            application.id,
                            isFavorite,
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
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                    }
                  },
                  icon:
                      isFavorite
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(
                            Icons.favorite_border,
                            color: AppColors.darkGrey,
                          ),
                  label: Text(
                    isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                    style: const TextStyle(color: AppColors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGrey,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Text(
                'Erreur lors du chargement: $error',
                style: const TextStyle(color: AppColors.darkGrey),
              ),
            ),
      ),
    );
  }
}

// Provider to fetch a single application by ID
final applicationProvider = StreamProvider.family<Application?, String>((
  ref,
  applicationId,
) {
  return FirebaseFirestore.instance
      .collection('applications')
      .doc(applicationId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.exists
                ? Application.fromFirestore(snapshot.data()!, snapshot.id)
                : null,
      );
});
