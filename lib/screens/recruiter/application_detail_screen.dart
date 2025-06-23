import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final applicationId = args?['applicationId'] as String?;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Détails de la candidature',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Text(
          'Écran de détails de la candidature à implémenter (ID: $applicationId)',
          style: const TextStyle(color: AppColors.darkGrey),
        ),
      ),
    );
  }
}
