<<<<<<< HEAD
import 'package:candid_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_routes.dart';
=======
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
<<<<<<< HEAD
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool rememberMe = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _onSignInPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Email invalide';
          break;
        case 'user-disabled':
          errorMessage = 'Compte désactivé';
          break;
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = 'Email ou mot de passe incorrect';
          break;
        default:
          errorMessage = 'Erreur de connexion';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur inattendue')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
=======
  bool rememberMe = false;

  void _onSignInPressed() {
    if (!rememberMe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must check 'Remember me' before signing in."),
        ),
      );
      return;
    }

    // Logique de connexion ici
    // Par exemple : Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
<<<<<<< HEAD
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to continue",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'johndoe@mail.com',
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
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text("Remember me"),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: const Text("Forgot password?"),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSignInPressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          "Sign In",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.signup);
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
=======
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome back",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sign in to continue",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(
                hintText: 'johndoe@mail.com',
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text("Remember me"),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text("Forgot password?"),
                ),
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSignInPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
        ),
      ),
    );
  }
}
