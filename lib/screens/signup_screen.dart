import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            const Text(
              "Welcome user",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text("Sign up to join", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Name',
                filled: true,
                fillColor: Color(0xFFF1F1F5),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Color(0xFFF1F1F5),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Color(0xFFF1F1F5),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Mobile',
                filled: true,
                fillColor: Color(0xFFF1F1F5),
              ),
            ),
            const SizedBox(height: 12),

            // Checkbox avec texte
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _agreedToTerms = newValue ?? false;
                    });
                  },
                ),
                const Text("I agree to the "),
                GestureDetector(
                  onTap: () {
                    // Ici tu peux rediriger vers  la page des conditions générales
                  },
                  child: const Text(
                    "Terms of Service",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _agreedToTerms
                      ? () {
                        // Action de création de compte ici
                      }
                      : null, // Désactive le bouton si pas coché
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
