import 'package:candid_app/services/auth_service.dart';
import 'package:candid_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

 // Remplacez _onSignUpPressed et _saveUserData par:
Future<void> _onSignUpPressed() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final auth = AuthService();
    final user = await auth.registerWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    // Sauvegarde des données supplémentaires
    await DatabaseService().updateUserProfile(user!.uid, {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _mobileController.text.trim(),
      'role': 'candidate',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  } catch (e) {
    // Gestion des erreurs
  } finally {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

  Future<void> _saveUserData(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'user', // Default role
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              const Text(
                "Welcome user",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Sign up to join",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  filled: true,
                  fillColor: Color(0xFFF1F1F5),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Color(0xFFF1F1F5),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Color(0xFFF1F1F5),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm Password',
                  filled: true,
                  fillColor: Color(0xFFF1F1F5),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  hintText: 'Mobile',
                  filled: true,
                  fillColor: Color(0xFFF1F1F5),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

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
                      //Navigator.pushNamed(context, AppRoutes.terms);
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
                onPressed: _isLoading ? null : _onSignUpPressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
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
      ),
    );
  }
}
