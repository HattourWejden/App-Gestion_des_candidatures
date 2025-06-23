import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChips({
    super.key,
    this.selectedFilter = 'all',
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'full-time', 'part-time', 'contract'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children:
            filters.map((filter) {
              return ChoiceChip(
                label: Text(filter == 'all' ? 'Tous' : filter),
                selected: selectedFilter == filter,
                selectedColor: AppColors.primaryBlue,
                labelStyle: TextStyle(
                  color:
                      selectedFilter == filter
                          ? Colors.white
                          : AppColors.darkGrey,
                ),
                onSelected: (selected) {
                  if (selected) {
                    onFilterChanged(filter);
                  }
                },
              );
            }).toList(),
      ),
    );
  }
}
