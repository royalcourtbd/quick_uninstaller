import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    required this.onChanged,
    required this.onClear,
    required this.child,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            autofocus: true,
            style: TextStyle(color: context.color.titleColor),
            decoration: InputDecoration(
              hintText: 'Search apps...',
              hintStyle: TextStyle(color: context.color.captionColor),
              prefixIcon: Icon(
                Icons.search,
                color: context.color.subTitleColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: context.color.subTitleColor),
                onPressed: onClear,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: context.color.cardColor,
            ),
            onChanged: onChanged,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
