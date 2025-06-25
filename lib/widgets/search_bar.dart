import 'package:flutter/material.dart';
import 'dart:async';
import '../../constants/colors.dart';

class SearchBar extends StatefulWidget {
  final Function(String) onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    print('SearchBar input: $value'); // Debug log
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(value);
    });
  }

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
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: AppColors.darkGrey),
            onPressed: () {
              print('Search cleared'); // Debug log
              widget.onChanged('');
              // Clear the text field
              context.findAncestorStateOfType<_SearchBarState>()?.setState(
                () {},
              );
            },
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}
