import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../constants/colors.dart';
import '../services/database_service.dart';
import '../models/job.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'open'; // Default value
  String _department = 'Non spécifié'; // Default value
  bool _isLoading = false;

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final job = Job(
        id: '', // Firestore generates ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        department: _department,
        applicationCount: 0,
        postedDate: null, // Set by DatabaseService.addJob
      );

      await DatabaseService().addJob(job);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offre créée avec succès')),
        );
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        String errorMessage = 'Erreur lors de la création de l\'offre';
        if (e.code == 'permission-denied') {
          errorMessage = 'Vous n\'avez pas la permission de créer une offre';
        } else if (e.code == 'unavailable') {
          errorMessage = 'Vérifiez votre connexion réseau';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur inattendue: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Créer une offre',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Titre de l\'offre',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.darkGrey),
                  ),
                  prefixIcon: const Icon(
                    Icons.work,
                    color: AppColors.primaryBlue,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description de l\'offre',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.darkGrey),
                  ),
                  prefixIcon: const Icon(
                    Icons.description,
                    color: AppColors.primaryBlue,
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkGrey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Statut'),
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Ouverte')),
                      DropdownMenuItem(value: 'closed', child: Text('Fermée')),
                      DropdownMenuItem(value: 'in_progress', child: Text('En cours')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkGrey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Département'),
                    value: _department,
                    items: const [
                      DropdownMenuItem(value: 'IT', child: Text('Informatique')),
                      DropdownMenuItem(value: 'HR', child: Text('RH')),
                      DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                      DropdownMenuItem(value: 'Non spécifié', child: Text('Non spécifié')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _department = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSavePressed,
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size.fromHeight(50)),
                    ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}