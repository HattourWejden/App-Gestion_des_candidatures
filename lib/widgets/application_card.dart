import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../models/application.dart';
import '../../services/firestore_service.dart';
import '../../providers.dart';

class ApplicationCard extends ConsumerWidget {
  final Application application;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final String role;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.showFavoriteButton = false,
    required this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if the application is favorited
    final isFavorite =
        showFavoriteButton
            ? ref
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
                )
            : false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'Candidat: ${application.candidateId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
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
            Text(
              'CV: ${application.cvUrl.isNotEmpty ? 'Disponible' : 'Non disponible'}',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
          ],
        ),
        trailing:
            showFavoriteButton
                ? IconButton(
                  icon:
                      isFavorite
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(
                            Icons.favorite_border,
                            color: AppColors.darkGrey,
                          ),
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
                )
                : null,
        onTap:
            onTap ??
            () {
              Navigator.pushNamed(
                context,
                AppRoutes.applicationDetail,
                arguments: {
                  'role': 'recruiter',
                  'applicationId': application.id,
                },
              );
            },
      ),
    );
  }
}
