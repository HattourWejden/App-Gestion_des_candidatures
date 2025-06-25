import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<String> filterOptions;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.filterOptions = const ['all', 'Informatique', 'RH', 'Marketing'],
  });

  @override
  Widget build(BuildContext context) {
    print('FilterChips build, selectedFilter: $selectedFilter'); // Debug log
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children:
            filterOptions.map((filter) {
              print(
                'Rendering chip: $filter, selected: ${selectedFilter == filter}',
              ); // Debug log
              return ChoiceChip(
                label: Text(filter == 'all' ? 'Tous' : filter),
                selected: selectedFilter == filter,
                onSelected: (selected) {
                  if (selected) {
                    print('Filter selected: $filter'); // Debug log
                    onFilterChanged(filter);
                  }
                },
                selectedColor: AppColors.primaryBlue,
                labelStyle: TextStyle(
                  color:
                      selectedFilter == filter
                          ? Colors.white
                          : AppColors.darkGrey,
                ),
                backgroundColor: AppColors.lightGrey,
              );
            }).toList(),
      ),
    );
  }
}
