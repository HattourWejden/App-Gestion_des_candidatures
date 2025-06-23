import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher une offre...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.darkGrey),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
        ),
        onChanged: onChanged,
      ),
    );
  }
}