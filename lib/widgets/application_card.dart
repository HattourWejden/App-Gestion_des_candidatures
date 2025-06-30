import 'package:candid_app/models/application.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firestore_service.dart';

class ApplicationCard extends ConsumerWidget {
  final Application application;
  final bool showFavoriteButton;
  final String role;
  final bool isFavorite; // New parameter
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle; // New parameter

  const ApplicationCard({
    super.key,
    required this.application,
    required this.showFavoriteButton,
    required this.role,
    required this.isFavorite,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          'Candidat: ${application.candidateId}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Statut: ${application.status}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing:
            showFavoriteButton
                ? IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed:
                      onFavoriteToggle != null
                          ? () {
                            onFavoriteToggle!();
                          }
                          : null,
                )
                : null,
        onTap: onTap,
      ),
    );
  }
}
