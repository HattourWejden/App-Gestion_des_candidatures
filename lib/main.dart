import 'package:candid_app/screens/CreateOffer_screen.dart';
import 'package:candid_app/screens/favorites_screen.dart';
import 'package:candid_app/screens/jobDetail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/colors.dart';
import 'constants/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
     

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
           title: 'Candidate App',
           debugShowCheckedModeBanner: false,
           locale: const Locale('fr', 'FR'),
           supportedLocales: const [Locale('fr', 'FR')],
           localizationsDelegates: const [
             GlobalMaterialLocalizations.delegate,
             GlobalWidgetsLocalizations.delegate,
             GlobalCupertinoLocalizations.delegate,
           ],
           theme: ThemeData(
             primaryColor: AppColors.primaryBlue,
             scaffoldBackgroundColor: AppColors.lightGrey,
             fontFamily: 'Roboto',
             elevatedButtonTheme: ElevatedButtonThemeData(
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primaryBlue,
                 foregroundColor: Colors.white,
                 textStyle: const TextStyle(fontWeight: FontWeight.bold),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
               ),
             ),
             outlinedButtonTheme: OutlinedButtonThemeData(
               style: OutlinedButton.styleFrom(
                 side: const BorderSide(color: AppColors.primaryBlue),
                 foregroundColor: AppColors.primaryBlue,
                 textStyle: const TextStyle(fontWeight: FontWeight.bold),
               ),
             ),
             textTheme: const TextTheme(
               bodyMedium: TextStyle(color: AppColors.black),
               bodySmall: TextStyle(color: AppColors.darkGrey),
             ),
           ),
           home: const SplashScreen(),
           routes: {
             AppRoutes.welcome: (_) => const WelcomeScreen(),
             AppRoutes.login: (_) => const LoginScreen(),
             AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
             AppRoutes.signup: (_) => const SignUpScreen(),
             AppRoutes.home: (_) => const HomeScreen(),
             AppRoutes.jobDetail: (_) => const JobDetailScreen(),
             AppRoutes.favorites: (_) => const FavoritesScreen(),
             AppRoutes.profile: (_) => const ProfileScreen(),
             AppRoutes.createoffer: (_) => const CreateOfferScreen(),
           },
         );
       }
     }