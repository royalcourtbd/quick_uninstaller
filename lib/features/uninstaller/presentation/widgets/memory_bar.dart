import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class MemoryBar extends StatelessWidget {
  const MemoryBar({
    super.key,
    required this.formattedMemory,
    required this.totalBytes,
  });

  final String formattedMemory;
  final int totalBytes;

  @override
  Widget build(BuildContext context) {
    if (totalBytes == 0) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: context.color.surfaceColor,
        child: Text(
          formattedMemory,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.color.subTitleColor, fontSize: 13),
        ),
      ),
    );
  }
}
