<<<<<<< HEAD
import 'package:candid_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
=======
import 'package:flutter/material.dart';
import 'dart:async';
import 'welcome_screen.dart'; // Redirection après le splash
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
<<<<<<< HEAD
        MaterialPageRoute(builder: (_) => const HomeScreen()),
=======
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
<<<<<<< HEAD
      body: Center(child: Image.asset('images/jglogo.webp', height: 180)),
=======
      body: Center(
        child: Image.asset(
          'images/jglogo.webp',
          height: 180,
        ),
      ),
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
    );
  }
}
