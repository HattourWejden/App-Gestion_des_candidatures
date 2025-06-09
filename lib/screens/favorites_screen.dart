import 'package:candid_app/constants/app_routes.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/job_model.dart';

import 'home_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Job> _favoriteJobs;

  @override
  void initState() {
    super.initState();
  
  }

  void _toggleFavorite(String jobId) {
    setState(() {
      _favoriteJobs = _favoriteJobs.where((job) => job.id != jobId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres favorites'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: _favoriteJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune offre favorite',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    child: const Text('Parcourir les offres'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _favoriteJobs.length,
              itemBuilder: (context, index) {
                final job = _favoriteJobs[index];
                return JobCard(
                  job: job,
                  onFavoritePressed: () => _toggleFavorite(job.id),
                );
              },
            ),
    );
  }
}