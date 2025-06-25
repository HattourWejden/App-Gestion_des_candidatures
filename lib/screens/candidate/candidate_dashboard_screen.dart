import 'package:candid_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_routes.dart';
import '../../constants/colors.dart';
import '../../widgets/job_offer_card.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/filter_chips.dart';
import '../../providers.dart';

class CandidateDashboardScreen extends ConsumerStatefulWidget {
  const CandidateDashboardScreen({super.key});

  @override
  ConsumerState<CandidateDashboardScreen> createState() =>
      _CandidateDashboardScreenState();
}

class _CandidateDashboardScreenState
    extends ConsumerState<CandidateDashboardScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          print(
            'Utilisateur non connecté, redirection vers login',
          ); // Debug log
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return const SizedBox.shrink();
        }
        print('Utilisateur connecté: ${user.uid}'); // Debug log
        return FutureBuilder<String?>(
          future: ref.read(authServiceProvider.notifier).getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (roleSnapshot.hasError) {
              print(
                'Erreur lors de la récupération du rôle: ${roleSnapshot.error}',
              ); // Debug log
            }
            if (roleSnapshot.data != 'candidate') {
              print(
                'Rôle non candidat: ${roleSnapshot.data}, redirection vers welcome',
              ); // Debug log
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              });
              return const SizedBox.shrink();
            }
            print('Rôle valide: ${roleSnapshot.data}'); // Debug log
            final offers = ref.watch(openOffersProvider);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Tableau de bord - Candidat'),
                backgroundColor: AppColors.primaryBlue,
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed:
                        () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                ],
              ),
              body: Column(
                children: [
                  custom.SearchBar(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                        print('Recherche: $_searchQuery'); // Debug log
                      });
                    },
                  ),
                  FilterChips(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                        print(
                          'Filtre sélectionné: $_selectedFilter',
                        ); // Debug log
                      });
                    },
                    filterOptions: const [
                      'all',
                      'Informatique',
                      'RH',
                      'Marketing',
                    ],
                  ),
                  Expanded(
                    child: offers.when(
                      data: (offerList) {
                        print(
                          'Offres ouvertes récupérées: ${offerList.length}',
                        ); // Debug log
                        final filteredOffers =
                            offerList.where((offer) {
                              final matchesSearch =
                                  offer.title.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  offer.description.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  );
                              final matchesFilter =
                                  _selectedFilter == 'all' ||
                                  offer.department ==
                                      _selectedFilter; // Filter by job type
                              return matchesSearch && matchesFilter;
                            }).toList();

                        print(
                          'Offres filtrées: ${filteredOffers.length}',
                        ); // Debug log
                        if (filteredOffers.isEmpty) {
                          return const Center(
                            child: Text(
                              'Aucune offre disponible',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredOffers.length,
                          itemBuilder: (context, index) {
                            final offer = filteredOffers[index];
                            print(
                              'Affichage de l\'offre: ${offer.title}, ID: ${offer.id}, Type: ${offer.department}',
                            ); // Debug log
                            // In CandidateDashboardScreen, inside ListView.builder
                            return JobOfferCard(
                              offer: offer,
                              role: 'candidate',
                              showFavoriteButton: true,
                              userId: user.uid,
                              onTap: () {
                                print(
                                  'Navigation vers jobDetail pour offerId: ${offer.id}',
                                );
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.jobDetail,
                                  arguments: {
                                    'role': 'candidate',
                                    'offerId': offer.id,
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (error, _) {
                        print(
                          'Erreur dans openOffersProvider: $error',
                        ); // Debug log
                        return Center(child: Text('Erreur: $error'));
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) {
        print('Erreur dans authServiceProvider: $e'); // Debug log
        return Scaffold(body: Center(child: Text('Erreur: $e')));
      },
    );
  }
}
