import 'package:candid_app/firebase_options.dart';
import 'package:candid_app/screens/auth/splash_screen.dart';
import 'package:candid_app/screens/candidate/candidate_dashboard_screen.dart';
import 'package:candid_app/screens/candidate/jobDetail_screen.dart';
import 'package:candid_app/screens/profile_screen.dart';
import 'package:candid_app/screens/recruiter/ApplicationsManagementScreen.dart';
import 'package:candid_app/screens/recruiter/CreateOffer_screen.dart';
import 'package:candid_app/screens/recruiter/favoritesscreen.dart';
import 'package:candid_app/screens/recruiter/recruiter_dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_routes.dart';
import 'constants/colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/recruiter/job_detail_screen.dart';
import 'screens/recruiter/application_detail_screen.dart';
import 'screens/candidate/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Application Manager',
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.lightGrey,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.createoffer: (context) => const CreateOfferScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.favorites: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final role = args?['role'] ?? 'candidate';
          if (role == 'recruiter') {
            return const FavoritesScreen();
          }
          return const CandidateFavoritesScreen();
        },
        AppRoutes.jobDetail: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final role = args?['role'] ?? 'candidate';
          if (role == 'recruiter') {
            return const JobDetailScreen();
          }
          return const CandidateJobDetailScreen();
        },
        AppRoutes.home: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final role = args?['role'] ?? 'candidate';
          if (role == 'recruiter') {
            return const RecruiterDashboardScreen();
          }
          return const CandidateDashboardScreen();
        },
        AppRoutes.applicationDetail:
            (context) => const ApplicationDetailScreen(),
        AppRoutes.applicationsManagement:
            (context) => const ApplicationsManagementScreen(),
      },
    );
  }
}
