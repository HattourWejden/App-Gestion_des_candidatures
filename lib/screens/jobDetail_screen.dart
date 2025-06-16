import 'package:candid_app/models/job.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../constants/app_routes.dart';
import '../services/database_service.dart';
import 'home_screen.dart'; // Import for Job model

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const SizedBox.shrink();
    }

    // Extract Job from arguments
    final Job? job = ModalRoute.of(context)?.settings.arguments as Job?;
    if (job == null) {
      return const Scaffold(
        body: Center(child: Text('Erreur : Offre non trouvée')),
      );
    }

    final favoritesAsync = ref.watch(favoritesProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(job.title, style: const TextStyle(color: Colors.white)),
        actions: [
          favoritesAsync.when(
            data: (favorites) {
              final isFavorite = favorites.contains(job.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await DatabaseService().toggleFavorite(user.uid, job.id, !isFavorite);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris')),
                  );
                },
              );
            },
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (_, __) => const Icon(Icons.error, color: Colors.white),
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Département: ${job.department}',
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Statut: ${job.status}',
                      style: TextStyle(
                        color: job.status == 'open' ? AppColors.primaryGreen : AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Candidatures: ${job.applicationCount}',
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Publié le: ${job.postedDate.toDate().toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.lightGrey),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.description,
                      style: const TextStyle(color: AppColors.darkGrey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (job.status == 'open')
              ElevatedButton(
                onPressed: () async {
                  try {
                    await DatabaseService().applyToJob(user.uid, job.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Candidature envoyée avec succès')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la candidature: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Postuler',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}