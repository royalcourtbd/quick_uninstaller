import 'package:flutter/material.dart';
import 'package:quick_uninstaller/shared/components/submit_button.dart';

class TwoWayActionButton extends StatelessWidget {
  const TwoWayActionButton({
    super.key,
    required this.theme,
    this.svgPictureForOkButton,
    this.svgPictureForCancelButton,
    required this.submitButtonTitle,
    required this.cancelButtonTitle,
    this.onSubmitButtonTap,
    this.onCancelButtonTap,
    this.submitButtonBgColor,
    this.submitButtonTextColor,
    this.cancelButtonBgColor,
    this.cancelButtonTextColor,
    this.isLoading = false,
  });

  final Widget? svgPictureForOkButton;
  final Widget? svgPictureForCancelButton;
  final String submitButtonTitle;
  final String cancelButtonTitle;
  final VoidCallback? onSubmitButtonTap;
  final VoidCallback? onCancelButtonTap;
  final Color? submitButtonBgColor;
  final Color? submitButtonTextColor;
  final Color? cancelButtonBgColor;
  final Color? cancelButtonTextColor;
  final bool isLoading;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Pre-compute colors to avoid repeated null checks in widget tree
    final submitBgColor = submitButtonBgColor ?? theme.colorScheme.primary;
    final submitTextColor =
        submitButtonTextColor ?? theme.colorScheme.onPrimary;
    final cancelBgColor = cancelButtonBgColor ?? Colors.white;
    final cancelTextColor = cancelButtonTextColor ?? Colors.black;

    // Pre-compute submit button icon to reduce nesting and improve readability
    final submitIcon = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(submitTextColor),
            ),
          )
        : svgPictureForOkButton;

    return Row(
      children: [
        Flexible(
          child: SubmitButton(
            theme: theme,
            svgPicture: svgPictureForCancelButton,
            title: cancelButtonTitle,
            onTap: onCancelButtonTap,
            buttonColor: cancelBgColor,
            textColor: cancelTextColor,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: SubmitButton(
            theme: theme,
            svgPicture: submitIcon,
            title: submitButtonTitle,
            onTap: isLoading ? null : onSubmitButtonTap,
            buttonColor: submitBgColor,
            textColor: submitTextColor,
          ),
        ),
      ],
    );
  }
}
