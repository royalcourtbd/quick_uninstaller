import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class SearchFab extends StatelessWidget {
  const SearchFab({
    super.key,
    required this.hasSearchQuery,
    required this.onPressed,
  });

  final bool hasSearchQuery;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (hasSearchQuery) return const SizedBox.shrink();
    return FloatingActionButton(
      backgroundColor: context.color.accentColor,
      onPressed: onPressed,
      child: Icon(Icons.search, color: context.color.whiteColor),
    );
  }
}
