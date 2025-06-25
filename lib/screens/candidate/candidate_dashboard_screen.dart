import 'package:candid_app/constants/app_routes.dart';
import 'package:candid_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/job_offer_card.dart';
import '../../widgets/search_bar.dart' as custom;
import '../../widgets/filter_chips.dart';
import '../../providers.dart';
import '../../services/auth_service.dart';

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
                        _searchQuery = query.trim();
                        print(
                          'Search query updated: $_searchQuery',
                        ); // Debug log
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
                        print(
                          'Départements disponibles: ${offerList.map((offer) => offer.department).toSet()}',
                        ); // Debug log
                        final filteredOffers =
                            offerList.where((offer) {
                              final searchQueryLower =
                                  _searchQuery.toLowerCase();
                              final title = offer.title?.toLowerCase() ?? '';
                              final description =
                                  offer.description?.toLowerCase() ?? '';
                              final matchesSearch =
                                  _searchQuery.isEmpty ||
                                  (title.contains(searchQueryLower) &&
                                      title.isNotEmpty) ||
                                  (description.contains(searchQueryLower) &&
                                      description.isNotEmpty);
                              final matchesFilter =
                                  _selectedFilter == 'all' ||
                                  (offer.department?.toLowerCase() ==
                                      _selectedFilter.toLowerCase());
                              print(
                                'Offre: ${offer.title}, Title: "$title", Description: "$description", SearchQuery: "$searchQueryLower", MatchesSearch: $matchesSearch, MatchesFilter: $matchesFilter',
                              ); // Debug log
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
                          key: ValueKey(
                            _searchQuery + _selectedFilter,
                          ), // Force rebuild
                          itemCount: filteredOffers.length,
                          itemBuilder: (context, index) {
                            final offer = filteredOffers[index];
                            print(
                              'Affichage de l\'offre: ${offer.title}, ID: ${offer.id}, Type: ${offer.department}',
                            ); // Debug log
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
                      error: (error, stack) {
                        print(
                          'Erreur dans openOffersProvider: $error, Stack: $stack',
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
      error: (e, stack) {
        print(
          'Erreur dans authServiceProvider: $e, Stack: $stack',
        ); // Debug log
        return Scaffold(body: Center(child: Text('Erreur: $e')));
      },
    );
  }
}
