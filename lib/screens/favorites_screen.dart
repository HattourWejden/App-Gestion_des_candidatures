import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../constants/app_routes.dart';
import '../services/database_service.dart';
import 'home_screen.dart'; // Import for Job model

// Provider for favorite jobs
final favoriteJobsProvider = StreamProvider<List<Job>>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final favoritesSnapshot = await DatabaseService().getUserFavorites(user.uid).first;
  final favoriteJobIds = ((favoritesSnapshot.data() as Map<String, dynamic>?)?['jobs'] as List<dynamic>?)?.cast<String>() ?? [];

  if (favoriteJobIds.isEmpty) {
    yield [];
    return;
  }

  final jobsStream = DatabaseService()
      .getJobs()
      .map((snapshot) => snapshot.docs
          .map((doc) => Job.fromFirestore(doc))
          .where((job) => favoriteJobIds.contains(job.id))
          .toList());

  await for (final jobs in jobsStream) {
    yield jobs;
  }
});

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

    final favoriteJobsAsync = ref.watch(favoriteJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Mes Favoris', style: TextStyle(color: Colors.white)),
      ),
      body: favoriteJobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(
              child: Text(
                'Aucune offre favorite',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  subtitle: Text(
                    job.department,
                    style: const TextStyle(color: AppColors.darkGrey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.yellow),
                    onPressed: () async {
                      try {
                        await DatabaseService().toggleFavorite(user.uid, job.id, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Retiré des favoris')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.jobDetail, arguments: job);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (error, _) => Center(
          child: Text(
            'Erreur: $error',
            style: const TextStyle(color: AppColors.darkGrey),
          ),
        ),
      ),
    );
  }
}