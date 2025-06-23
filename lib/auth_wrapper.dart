import 'package:candid_app/screens/candidate/candidate_dashboard_screen.dart';
import 'package:candid_app/screens/recruiter/recruiter_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../screens/auth/welcome_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const WelcomeScreen();
        }
        // Fetch user role from Firestore
        return FutureBuilder<String?>(
          future: ref.read(authServiceProvider.notifier).getUserRole(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final role = snapshot.data;
            if (role == 'recruiter') {
              return const RecruiterDashboardScreen();
            } else if (role == 'candidate') {
              return const CandidateDashboardScreen();
            } else {
              // Handle invalid role (e.g., logout or error screen)
              return const WelcomeScreen();
            }
          },
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, _) => Scaffold(body: Center(child: Text('Erreur: $error'))),
    );
  }
}
