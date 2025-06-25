import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firestore_service.dart';

class ApplicationFormDialog extends StatefulWidget {
  final String jobId;
  final String userId;
  final WidgetRef ref;

  const ApplicationFormDialog({
    super.key,
    required this.jobId,
    required this.userId,
    required this.ref,
  });

  @override
  _ApplicationFormDialogState createState() => _ApplicationFormDialogState();
}

class _ApplicationFormDialogState extends State<ApplicationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _name, _email, _phone, _education, _experience, _skills, _languages, _interests, _coverLetter;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Formulaire de candidature'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Nom complet', (v) => _name = v),
              _buildTextField(
                'Email',
                (v) => _email = v,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              _buildTextField('Numéro de téléphone', (v) => _phone = v, keyboardType: TextInputType.phone),
              _buildTextArea('Formation', (v) => _education = v),
              _buildTextArea('Expériences professionnelles', (v) => _experience = v),
              _buildTextArea('Compétences', (v) => _skills = v),
              _buildTextArea('Langues', (v) => _languages = v),
              _buildTextArea('Centres d’intérêt (optionnel)', (v) => _interests = v, required: false),
              _buildTextArea('Lettre de motivation', (v) => _coverLetter = v),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              try {
                await widget.ref.read(firestoreServiceProvider).applyToJob(
                      widget.jobId,
                      widget.userId,
                      null, // Pas de cvUrl
                      additionalData: {
                        'name': _name,
                        'email': _email,
                        'phone': _phone,
                        'education': _education,
                        'experience': _experience,
                        'skills': _skills,
                        'languages': _languages,
                        'interests': _interests,
                        'coverLetter': _coverLetter,
                      },
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Candidature envoyée avec succès')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors de l\'envoi: $e')),
                );
              }
            }
          },
          child: const Text('Envoyer'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, void Function(String?) onSaved,
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: keyboardType,
        validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildTextArea(String label, void Function(String?) onSaved, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        maxLines: 3,
        validator: (value) => required && (value == null || value.isEmpty) ? 'Champ requis' : null,
        onSaved: onSaved,
      ),
    );
  }
}
