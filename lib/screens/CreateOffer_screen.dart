import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../services/database_service.dart';

final createOfferFormProvider = StateProvider<Map<String, String>>((ref) => {
      'title': '',
      'description': '',
      'status': 'open',
      'department': 'Informatique',
    });

class CreateOfferScreen extends ConsumerWidget {
  const CreateOfferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(createOfferFormProvider);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Créer une offre', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              // Champ titre
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Titre',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.title, color: AppColors.primaryBlue),
                ),
                initialValue: formState['title'],
                onChanged: (value) {
                  ref.read(createOfferFormProvider.notifier).update((state) => {...state, 'title': value});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Champ description
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.description, color: AppColors.primaryBlue),
                ),
                initialValue: formState['description'],
                maxLines: 5,
                onChanged: (value) {
                  ref.read(createOfferFormProvider.notifier).update((state) => {...state, 'description': value});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Sélecteur de statut
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Statut',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.flag, color: AppColors.primaryBlue),
                ),
                value: formState['status'],
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Ouverte')),
                  DropdownMenuItem(value: 'closed', child: Text('Fermée')),
                  DropdownMenuItem(value: 'in_progress', child: Text('En cours')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(createOfferFormProvider.notifier).update((state) => {...state, 'status': value});
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un statut';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Sélecteur de département
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Département',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.business, color: AppColors.primaryBlue),
                ),
                value: formState['department'],
                items: const [
                  DropdownMenuItem(value: 'Informatique', child: Text('Informatique')),
                  DropdownMenuItem(value: 'RH', child: Text('RH')),
                  DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(createOfferFormProvider.notifier).update((state) => {...state, 'department': value});
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un département';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Bouton de soumission
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      await DatabaseService().addJob({
                        'title': formState['title'],
                        'description': formState['description'],
                        'status': formState['status'],
                        'department': formState['department'],
                        'application_count': 0,
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offre créée avec succès')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de la création: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Créer l\'offre',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}