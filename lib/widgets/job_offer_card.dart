import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/job_offer.dart';
import '../../services/firestore_service.dart';

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
                  icon: const Icon(Icons.star, color: Colors.yellow),
                  onPressed: () async {
                    try {
                      await ref
                          .read(firestoreServiceProvider)
                          .toggleFavorite(
                            userId!,
                            offer.id,
                            false, // Remove from favorites
                            'job',
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Retiré des favoris')),
                      );
                    } catch (e) {
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
