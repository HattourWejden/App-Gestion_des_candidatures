import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _rememberMeError; // To store checkbox error message

  final _formKey = GlobalKey<FormState>();

  Future<void> _onSignInPressed() async {
    // Reset error message
    setState(() {
      _rememberMeError = null;
    });

    // Validate form fields and checkbox
    if (!_formKey.currentState!.validate() || !rememberMe) {
      if (!rememberMe) {
        setState(() {
          _rememberMeError = 'Veuillez cocher "Se souvenir de moi"';
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
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
          errorMessage = 'Erreur de connexion: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur inattendue: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = screenHeight * 0.2;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: paddingTop, left: 24.0, right: 24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    "Bienvenue de nouveau",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Connectez-vous pour continuer",
                    style: TextStyle(color: AppColors.darkGrey),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'johndoe@mail.com',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.darkGrey),
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.darkGrey),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.primaryBlue,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    _rememberMeError =
                                        null; // Clear error when checkbox is toggled
                                  });
                                },
                                activeColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side:
                                      _rememberMeError != null
                                          ? const BorderSide(
                                            color: Color.fromARGB(
                                              255,
                                              194,
                                              53,
                                              43,
                                            ),
                                          )
                                          : const BorderSide(
                                            color: Colors.transparent,
                                          ), // Default to transparent
                                ),
                                semanticLabel: 'Se souvenir de moi',
                              ),
                              const Text("Se souvenir de moi"),
                            ],
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                );
                              },
                              child: const Text(
                                "Mot de passe oublié ?",
                                style: TextStyle(color: AppColors.primaryBlue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_rememberMeError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Text(
                            _rememberMeError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _onSignInPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Se connecter",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas de compte ? "),
                      GestureDetector(
                        onTap:
                            () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Image.asset(
              'images/jglogo-removebg-preview.png',
              height: 100,
              width: 100,
            ),
          ),
        ],
      ),
    );
  }
}
