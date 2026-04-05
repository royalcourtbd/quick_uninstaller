import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.title,
    this.onTap,
    this.fontFamily,
    this.buttonColor = Colors.white,
    this.textColor,
    this.svgPicture,
    this.buttonHeight,
    required this.theme,
  });

  final String title;
  final VoidCallback? onTap;
  final Color buttonColor;
  final Color? textColor;
  final Widget? svgPicture;
  final ThemeData theme;
  final String? fontFamily;
  final double? buttonHeight;

  // Const values for better performance
  static const _horizontalPadding = EdgeInsets.symmetric(horizontal: 10);
  static const _borderRadius = BorderRadius.all(Radius.circular(50));
  static const _iconSpacing = SizedBox(width: 10);
  static const _defaultHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    // Cache theme text style to avoid repeated access
    final baseTextStyle = theme.textTheme.bodyMedium!;

    // Pre-compute text style to avoid complex operations in widget tree
    final textStyle = baseTextStyle.copyWith(
      color: textColor ?? baseTextStyle.color,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      fontFamily: fontFamily ?? baseTextStyle.fontFamily,
    );

    // Pre-compute children list to avoid conditional building in widget tree
    final children = <Widget>[
      if (svgPicture != null) ...[svgPicture!, _iconSpacing],
      Flexible(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const Key('SubmitButton'),
        alignment: Alignment.center,
        width: double.infinity,
        padding: _horizontalPadding,
        height: buttonHeight ?? _defaultHeight,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          color: buttonColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
