import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'constants/colors.dart';
<<<<<<< HEAD
import 'constants/app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
=======
import 'routes/app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/signup_screen.dart';

void main() {
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
<<<<<<< HEAD
  const MyApp({super.key});
=======
  const MyApp({super.key}); // meilleure pratique avec `const`
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candidate App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
<<<<<<< HEAD
        fontFamily: 'Roboto',
=======
        fontFamily: 'Roboto', // tu peux définir une police custom si besoin
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryBlue),
            foregroundColor: AppColors.primaryBlue,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
<<<<<<< HEAD
      home: const HomeScreen(),
=======
      home: const SplashScreen(),
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.signup: (_) => const SignUpScreen(),
<<<<<<< HEAD
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.jobDetail: (_) => const JobDetailScreen(),
        AppRoutes.favorites: (_) => const FavoritesScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
=======
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
      },
    );
  }
}
