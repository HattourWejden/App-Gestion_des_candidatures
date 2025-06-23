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
    final offers = ref.watch(openOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord - Candidat'),
        backgroundColor: AppColors.primaryBlue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          custom.SearchBar(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          FilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          Expanded(
            child: offers.when(
              data: (offerList) {
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
                          offer.contractType == _selectedFilter;
                      return matchesSearch && matchesFilter;
                    }).toList();

                if (filteredOffers.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune offre disponible',
                      style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredOffers.length,
                  itemBuilder: (context, index) {
                    final offer = filteredOffers[index];
                    return JobOfferCard(
                      offer: offer,
                      role: 'candidate',
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.jobDetail,
                            arguments: {
                              'role': 'candidate',
                              'offerId': offer.id,
                            },
                          ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
