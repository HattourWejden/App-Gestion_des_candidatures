import 'package:candid_app/models/application.dart';
import 'package:candid_app/services/auth_service.dart';
import 'package:candid_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../providers.dart';

// ApplicationCard Widget for reusability
class ApplicationCard extends StatelessWidget {
  final Application application;
  final bool showFavoriteButton;
  final String role;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ApplicationCard({
    super.key,
    required this.application,
    this.showFavoriteButton = false,
    required this.role,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, AppColors.lightGrey.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Text(
                application.name?.substring(0, 1).toUpperCase() ?? 'C',
                style: GoogleFonts.roboto(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              application.name ?? 'Candidat ${application.candidateId}',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    application.status.toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yy').format(application.appliedAt),
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.darkGrey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            trailing:
                showFavoriteButton
                    ? IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : AppColors.darkGrey,
                      ),
                      onPressed: onFavoriteToggle,
                    )
                    : null,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (application.email != null)
                      _buildInfoRow(Icons.email, 'Email', application.email!),
                    if (application.phone != null)
                      _buildInfoRow(
                        Icons.phone,
                        'Téléphone',
                        application.phone!,
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildActionButton(
                          context,
                          'Voir détails',
                          Icons.visibility,
                          AppColors.primaryBlue,
                          () => _showApplicationDetails(context, application),
                        ),
                        _buildActionButton(
                          context,
                          'Modifier statut',
                          Icons.edit,
                          AppColors.primaryGreen,
                          () async {
                            final newStatus = await _showStatusDialog(
                              context,
                              application.status,
                            );
                            if (newStatus != null &&
                                newStatus != application.status) {
                              try {
                                await ProviderScope.containerOf(context)
                                    .read(firestoreServiceProvider)
                                    .updateApplicationStatus(
                                      application.id,
                                      newStatus,
                                    );
                                ProviderScope.containerOf(
                                  context,
                                ).refresh(allApplicationsProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Statut mis à jour'),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        _buildActionButton(
                          context,
                          'Supprimer',
                          Icons.delete,
                          Colors.red,
                          () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text(
                                      'Confirmer la suppression',
                                    ),
                                    content: const Text(
                                      'Voulez-vous supprimer cette candidature ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              try {
                                await ProviderScope.containerOf(context)
                                    .read(firestoreServiceProvider)
                                    .deleteApplication(application.id);
                                ProviderScope.containerOf(
                                  context,
                                ).refresh(allApplicationsProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Candidature supprimée'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.primaryGreen;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
      default:
        return AppColors.primaryBlue;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }

  void _showApplicationDetails(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Détails de la candidature',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow(
                    Icons.person,
                    'Candidat',
                    application.candidateId,
                  ),
                  _buildInfoRow(Icons.info, 'Statut', application.status),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormat('dd/MM/yyyy').format(application.appliedAt),
                  ),
                  if (application.cvUrl != null)
                    _buildInfoRow(Icons.link, 'CV URL', application.cvUrl!),
                  if (application.name != null)
                    _buildInfoRow(Icons.person, 'Nom', application.name!),
                  if (application.email != null)
                    _buildInfoRow(Icons.email, 'Email', application.email!),
                  if (application.phone != null)
                    _buildInfoRow(Icons.phone, 'Téléphone', application.phone!),
                  if (application.education != null)
                    _buildInfoRow(
                      Icons.school,
                      'Éducation',
                      application.education!,
                    ),
                  if (application.experience != null)
                    _buildInfoRow(
                      Icons.work,
                      'Expérience',
                      application.experience!,
                    ),
                  if (application.skills != null)
                    _buildInfoRow(
                      Icons.star,
                      'Compétences',
                      application.skills!,
                    ),
                  if (application.languages != null)
                    _buildInfoRow(
                      Icons.language,
                      'Langues',
                      application.languages!,
                    ),
                  if (application.coverLetter != null)
                    _buildInfoRow(
                      Icons.description,
                      'Lettre de motivation',
                      application.coverLetter!,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: GoogleFonts.roboto(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<String?> _showStatusDialog(
    BuildContext context,
    String currentStatus,
  ) async {
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Modifier le statut',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusOption(
                  context,
                  'En attente',
                  'pending',
                  currentStatus,
                ),
                _buildStatusOption(
                  context,
                  'En cours',
                  'in_progress',
                  currentStatus,
                ),
                _buildStatusOption(
                  context,
                  'Acceptée',
                  'accepted',
                  currentStatus,
                ),
                _buildStatusOption(
                  context,
                  'Rejetée',
                  'rejected',
                  currentStatus,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.roboto(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String title,
    String value,
    String currentStatus,
  ) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 16,
          color:
              value == currentStatus
                  ? AppColors.primaryBlue
                  : AppColors.darkGrey,
        ),
      ),
      trailing:
          value == currentStatus
              ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
              : null,
      onTap: () => Navigator.pop(context, value),
    );
  }
}

// ApplicationsManagementScreen
final allApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('No authenticated user, returning empty stream');
    return const Stream.empty();
  }
  print('Fetching all applications from Firestore');
  return FirebaseFirestore.instance
      .collection('applications')
      .snapshots()
      .map((snapshot) {
        final applications =
            snapshot.docs
                .map(
                  (doc) => Application.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList();
        print(
          'Fetched ${applications.length} applications: ${applications.map((app) => app.id)}',
        );
        return applications;
      })
      .handleError((error, stack) {
        print('Error in allApplicationsProvider: $error, Stack: $stack');
        return <Application>[];
      });
});

class ApplicationsManagementScreen extends ConsumerWidget {
  const ApplicationsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const SizedBox.shrink();
        }

        return FutureBuilder<String?>(
          future: ref.read(authServiceProvider.notifier).getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.data != 'recruiter') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              });
              return const SizedBox.shrink();
            }

            final applicationsAsync = ref.watch(allApplicationsProvider);

            return applicationsAsync.when(
              data: (applications) {
                return Scaffold(
                  backgroundColor: AppColors.lightGrey,
                  appBar: AppBar(
                    backgroundColor: AppColors.primaryBlue,
                    title: Text(
                      'Gestion des Candidatures',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    elevation: 0,
                    centerTitle: true,
                  ),
                  body:
                      applications.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: AppColors.darkGrey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune candidature disponible',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Vérifiez à nouveau plus tard',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: AppColors.darkGrey.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.04,
                            ),
                            itemCount: applications.length,
                            itemBuilder: (context, index) {
                              final application = applications[index];
                              final isFavoriteAsync = ref.watch(
                                favoriteApplicationsProvider(user.uid),
                              );
                              return isFavoriteAsync.when(
                                data: (favApps) {
                                  final isFavorite = favApps.any(
                                    (app) => app.id == application.id,
                                  );
                                  return ApplicationCard(
                                    application: application,
                                    showFavoriteButton: true,
                                    role: 'recruiter',
                                    isFavorite: isFavorite,
                                    onFavoriteToggle: () async {
                                      try {
                                        await ref
                                            .read(firestoreServiceProvider)
                                            .toggleFavorite(
                                              user.uid,
                                              application.id,
                                              isFavorite,
                                              'application',
                                            );
                                        ref.invalidate(
                                          favoriteApplicationsProvider(
                                            user.uid,
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isFavorite
                                                  ? 'Retiré des favoris'
                                                  : 'Ajouté aux favoris',
                                            ),
                                            backgroundColor:
                                                isFavorite
                                                    ? Colors.red
                                                    : AppColors.primaryGreen,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Erreur: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                                loading:
                                    () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                error:
                                    (error, stack) => Center(
                                      child: Text(
                                        'Erreur: $error',
                                        style: GoogleFonts.roboto(
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                    ),
                              );
                            },
                          ),
                  bottomNavigationBar: BottomNavigationBar(
                    selectedItemColor: AppColors.primaryBlue,
                    unselectedItemColor: AppColors.darkGrey,
                    currentIndex: 0,
                    onTap: (index) {
                      if (index == 1) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.favorites,
                          arguments: {'role': 'recruiter'},
                        );
                      } else if (index == 2) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.profile,
                        );
                      }
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.assignment),
                        label: 'Candidatures',
                        tooltip: 'Voir toutes les candidatures',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.star),
                        label: 'Favoris',
                        tooltip: 'Voir les favoris',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Profil',
                        tooltip: 'Voir le profil',
                      ),
                    ],
                    backgroundColor: Colors.white,
                    elevation: 8,
                    selectedLabelStyle: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.roboto(),
                  ),
                );
              },
              loading:
                  () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, _) => Scaffold(
                    body: Center(
                      child: Text(
                        'Erreur lors du chargement: $error',
                        style: GoogleFonts.roboto(color: AppColors.darkGrey),
                      ),
                    ),
                  ),
            );
          },
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Scaffold(
            body: Center(
              child: Text(
                'Erreur: $e',
                style: GoogleFonts.roboto(color: AppColors.darkGrey),
              ),
            ),
          ),
    );
  }
}
