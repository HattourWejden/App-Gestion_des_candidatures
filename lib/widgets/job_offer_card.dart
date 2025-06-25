import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/job_offer.dart';
import '../../services/firestore_service.dart';
import '../../providers.dart';

class JobOfferCard extends ConsumerWidget {
  final JobOffer offer;
  final String? role;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final String? userId;

  const JobOfferCard({
    super.key,
    required this.offer,
    this.role,
    this.onTap,
    this.showFavoriteButton = false,
    this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if the job is favorited
    final isFavorite =
        showFavoriteButton && userId != null
            ? ref
                .watch(favoriteJobsProvider(userId!))
                .when(
                  data: (jobs) => jobs.any((job) => job.id == offer.id),
                  loading: () => false,
                  error: (error, stack) {
                    print(
                      'Error in favoriteJobsProvider: $error, Stack: $stack',
                    ); // Debug log
                    return false;
                  },
                )
            : false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          offer.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${offer.contractType}',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
            Text(
              'Publié le: ${DateFormat('dd/MM/yyyy').format(offer.createdAt)}',
              style: const TextStyle(color: AppColors.darkGrey),
            ),
          ],
        ),
        trailing:
            showFavoriteButton && userId != null
                ? IconButton(
                  icon:
                      isFavorite
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(
                            Icons.favorite_border,
                            color: AppColors.darkGrey,
                          ),
                  onPressed: () async {
                    print(
                      'Toggling favorite for job: ${offer.id}, user: $userId, current state: $isFavorite',
                    ); // Debug log
                    try {
                      await ref
                          .read(firestoreServiceProvider)
                          .toggleFavorite(userId!, offer.id, isFavorite, 'job');
                      print('Favorite toggled successfully'); // Debug log
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Retiré des favoris'
                                : 'Ajouté aux favoris',
                          ),
                        ),
                      );
                      // Force refresh of favoriteJobsProvider
                      ref.invalidate(favoriteJobsProvider(userId!));
                    } catch (e, stack) {
                      print(
                        'Error toggling favorite: $e, Stack: $stack',
                      ); // Debug log
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                    }
                  },
                )
                : null,
        onTap: onTap,
      ),
    );
  }
}
