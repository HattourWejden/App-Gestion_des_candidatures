import 'package:candid_app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../constants/app_routes.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/job.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const Center(child: Text('Utilisateur non connecté'));
        }

        final user = snapshot.data!;
        final jobsAsync = ref.watch(jobsProvider);
        final statsAsync = ref.watch(statsProvider);
        final favoritesAsync = ref.watch(favoritesProvider(user.uid));

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
                  await authService.signOut();
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
                    hintText: 'Rechercher une offre...',
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
                    _buildFilterDropdown(
                      context,
                      hint: 'Statut',
                      value: ref.watch(filterProvider)['status'],
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tous')),
                        DropdownMenuItem(
                          value: 'open',
                          child: Text('Ouvertes'),
                        ),
                        DropdownMenuItem(
                          value: 'closed',
                          child: Text('Fermées'),
                        ),
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
                    _buildFilterDropdown(
                      context,
                      hint: 'Département',
                      value: ref.watch(filterProvider)['department'],
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tous')),
                        DropdownMenuItem(
                          value: 'IT',
                          child: Text('Informatique'),
                        ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Offres totales',
                              stats['total_jobs'].toString(),
                              AppColors.primaryBlue,
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Offres actives',
                              stats['active_jobs'].toString(),
                              AppColors.primaryGreen,
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Candidatures',
                              stats['total_applications'].toString(),
                              AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => const Text(
                      'Erreur lors du chargement des statistiques',
                    ),
              ),
              // Liste des offres
              Expanded(
                child: favoritesAsync.when(
                  data:
                      (favorites) => jobsAsync.when(
                        data: (jobs) {
                          if (jobs.isEmpty) {
                            return const Center(
                              child: Text('Aucune offre trouvée'),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: jobs.length,
                            itemBuilder: (context, index) {
                              final job = jobs[index];
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Statut: ${job.status}',
                                        style: TextStyle(
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                      Text(
                                        'Département: ${job.department}',
                                        style: TextStyle(
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                      Text(
                                        'Candidatures: ${job.applicationCount}',
                                        style: TextStyle(
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppColors.primaryBlue,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await DatabaseService().toggleFavorite(
                                          user.uid,
                                          job.id,
                                          !isFavorite,
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
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Erreur: $e')),
                                        );
                                      }
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
                          );
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (e, _) => const Center(
                              child: Text(
                                'Erreur lors du chargement des offres',
                              ),
                            ),
                      ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, _) => const Center(
                        child: Text('Erreur lors du chargement des favoris'),
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
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (index == 1) {
                Navigator.pushNamed(context, AppRoutes.favorites);
              } else if (index == 2) {
                Navigator.pushNamed(context, AppRoutes.profile);
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoris'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: AppColors.darkGrey),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, {
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          hint: Text(hint),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
