import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../services/database_service.dart';

final createOfferFormProvider = StateProvider<Map<String, String>>(
  (ref) => {
    'title': '',
    'description': '',
    'status': 'open',
    'department': 'Informatique',
  },
);

class CreateOfferScreen extends ConsumerStatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(createOfferFormProvider);
    titleController = TextEditingController(text: formState['title']);
    descriptionController = TextEditingController(
      text: formState['description'],
    );

    titleController.addListener(() {
      ref
          .read(createOfferFormProvider.notifier)
          .update((state) => {...state, 'title': titleController.text});
    });

    descriptionController.addListener(() {
      ref
          .read(createOfferFormProvider.notifier)
          .update(
            (state) => {...state, 'description': descriptionController.text},
          );
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createOfferFormProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Créer une offre',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(
                    Icons.title,
                    color: AppColors.primaryBlue,
                  ),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Veuillez entrer un titre'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(
                    Icons.description,
                    color: AppColors.primaryBlue,
                  ),
                ),
                maxLines: 5,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Veuillez entrer une description'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Statut',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(
                    Icons.flag,
                    color: AppColors.primaryBlue,
                  ),
                ),
                value: formState['status'],
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Ouverte')),
                  DropdownMenuItem(value: 'closed', child: Text('Fermée')),
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Text('En cours'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(createOfferFormProvider.notifier)
                        .update((state) => {...state, 'status': value});
                  }
                },
                validator:
                    (value) =>
                        (value == null)
                            ? 'Veuillez sélectionner un statut'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Département',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(
                    Icons.business,
                    color: AppColors.primaryBlue,
                  ),
                ),
                value: formState['department'],
                items: const [
                  DropdownMenuItem(
                    value: 'Informatique',
                    child: Text('Informatique'),
                  ),
                  DropdownMenuItem(value: 'RH', child: Text('RH')),
                  DropdownMenuItem(
                    value: 'Marketing',
                    child: Text('Marketing'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(createOfferFormProvider.notifier)
                        .update((state) => {...state, 'department': value});
                  }
                },
                validator:
                    (value) =>
                        (value == null)
                            ? 'Veuillez sélectionner un département'
                            : null,
              ),
              const SizedBox(height: 32),
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
                      // ✅ Important: signaler à Home que l’offre est créée
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Offre créée avec succès'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de la création: $e'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
