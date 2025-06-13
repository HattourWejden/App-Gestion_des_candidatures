import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../constants/app_routes.dart';
import '../services/database_service.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String status;
  final String department;
  final int applicationCount;
  final Timestamp postedDate;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.department,
    required this.applicationCount,
    required this.postedDate,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      department: data['department'] ?? '',
      applicationCount: data['application_count'] ?? 0,
      postedDate: data['postedDate'] ?? Timestamp.now(),
    );
  }
}


final jobsProvider = StreamProvider<List<Job>>((ref) {
  return DatabaseService().getJobs().map(
    (snapshot) => snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList(),
  );
});

// Provider pour les statistiques
final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final jobsSnapshot =
      await FirebaseFirestore.instance.collection('jobs').get();
  final applicationsSnapshot =
      await FirebaseFirestore.instance.collectionGroup('applications').get();
  return {
    'total_jobs': jobsSnapshot.docs.length,
    'active_jobs':
        jobsSnapshot.docs.where((doc) => doc['status'] == 'open').length,
    'total_applications': applicationsSnapshot.docs.length,
  };
});

// Provider pour les favoris
final favoritesProvider = StreamProvider.family<List<String>, String>((
  ref,
  userId,
) {
  return DatabaseService().getUserFavorites(userId).map((snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return (data?['jobs'] as List<dynamic>?)?.cast<String>() ?? [];
  });
});

// Provider pour les filtres
final filterProvider = StateProvider<Map<String, String?>>(
  (ref) => {'status': null, 'department': null, 'search': null},
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    final jobsAsync = ref.watch(jobsProvider);
    final statsAsync = ref.watch(statsProvider);
    final favoritesAsync = ref.watch(favoritesProvider(user.uid));
    final filters = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une offre ou candidature...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryBlue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                ref
                    .read(filterProvider.notifier)
                    .update((state) => {...state, 'search': value});
              },
            ),
          ),
          // Filtres rapides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: const Text('Statut'),
                  value: filters['status'],
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(value: 'open', child: Text('Ouvertes')),
                    DropdownMenuItem(value: 'closed', child: Text('Fermées')),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('En cours'),
                    ),
                  ],
                  onChanged: (value) {
                    ref
                        .read(filterProvider.notifier)
                        .update((state) => {...state, 'status': value});
                  },
                ),
                DropdownButton<String>(
                  hint: const Text('Département'),
                  value: filters['department'],
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(value: 'IT', child: Text('Informatique')),
                    DropdownMenuItem(value: 'HR', child: Text('RH')),
                    DropdownMenuItem(
                      value: 'Marketing',
                      child: Text('Marketing'),
                    ),
                  ],
                  onChanged: (value) {
                    ref
                        .read(filterProvider.notifier)
                        .update((state) => {...state, 'department': value});
                  },
                ),
              ],
            ),
          ),
          // Statistiques rapides
          statsAsync.when(
            data:
                (stats) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Offres totales',
                        stats['total_jobs'].toString(),
                        AppColors.primaryBlue,
                      ),
                      _buildStatCard(
                        'Offres actives',
                        stats['active_jobs'].toString(),
                        AppColors.primaryGreen,
                      ),
                      _buildStatCard(
                        'Candidatures',
                        stats['total_applications'].toString(),
                        AppColors.darkGrey,
                      ),
                    ],
                  ),
                ),
            loading: () => const CircularProgressIndicator(),
            error:
                (e, _) =>
                    const Text('Erreur lors du chargement des statistiques'),
          ),
          // Liste des offres
          Expanded(
            child: jobsAsync.when(
              data: (jobs) {
                final filteredJobs =
                    jobs.where((job) {
                      final statusMatch =
                          filters['status'] == null ||
                          job.status == filters['status'];
                      final deptMatch =
                          filters['department'] == null ||
                          job.department == filters['department'];
                      final searchMatch =
                          filters['search'] == null ||
                          job.title.toLowerCase().contains(
                            filters['search']!.toLowerCase(),
                          ) ||
                          job.description.toLowerCase().contains(
                            filters['search']!.toLowerCase(),
                          );
                      return statusMatch && deptMatch && searchMatch;
                    }).toList();

                if (filteredJobs.isEmpty) {
                  return const Center(child: Text('Aucune offre trouvée'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return favoritesAsync.when(
                      data: (favorites) {
                        final isFavorite = favorites.contains(job.id);
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              job.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Statut: ${job.status}',
                                  style: TextStyle(color: AppColors.darkGrey),
                                ),
                                Text(
                                  'Département: ${job.department}',
                                  style: TextStyle(color: AppColors.darkGrey),
                                ),
                                Text(
                                  'Candidatures: ${job.applicationCount}',
                                  style: TextStyle(color: AppColors.darkGrey),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                                color: AppColors.primaryBlue,
                              ),
                              onPressed: () async {
                                await DatabaseService().toggleFavorite(
                                  user.uid,
                                  job.id,
                                  !isFavorite,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFavorite
                                          ? 'Retiré des favoris'
                                          : 'Ajouté aux favoris',
                                    ),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.jobDetail,
                                arguments: job,
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error:
                          (e, _) => const Text(
                            'Erreur lors du chargement des favoris',
                          ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, _) => const Center(
                    child: Text('Erreur lors du chargement des offres'),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createoffer);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.darkGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Offres'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.jobDetail);
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.favorites);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: AppColors.darkGrey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
