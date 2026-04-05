import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/config/app_screen.dart';
import 'package:quick_uninstaller/core/external_libs/flutter_animated_dialog/src/animated_dialog.dart';
import 'package:quick_uninstaller/core/static/ui_const.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/shared/components/two_way_action_button.dart';

class RemoveDialog extends StatelessWidget {
  const RemoveDialog({super.key, required this.title, required this.onRemove});

  final String title;
  final Future<void> Function() onRemove;

  // Static const values for better performance
  static const _dialogInsetPadding = EdgeInsets.symmetric(horizontal: 20);
  static const _contentPadding = EdgeInsets.only(top: 20);
  static const _dialogElevation = 0.0;
  static const _deleteText = 'Delete';
  static const _warningText = 'You Will Not be able to recover this history';
  static const _cancelText = 'Cancel';

  static Future<void> show({
    required BuildContext context,
    required String title,
    required Future<void> Function() onRemove,
  }) async {
    await showAnimatedDialog<void>(
      context: context,
      builder: (_) => RemoveDialog(onRemove: onRemove, title: title),
      animationType: DialogTransitionType.scale,
      curve: Curves.fastOutSlowIn,
      barrierDismissible: true,
    );
  }

  // Extract async function to reduce widget tree complexity
  Future<void> _handleDelete(BuildContext context) async {
    if (context.mounted) context.navigatorPop<void>();
    await onRemove();
  }

  @override
  Widget build(BuildContext context) {
    // Cache theme and context extensions to avoid repeated lookups
    final theme = Theme.of(context);
    final isDarkMode = context.isDarkMode;
    final subTitleColor = context.color.subTitleColor;

    // Pre-compute text styles to avoid inline computation
    final titleTextStyle = theme.textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.bold,
    );

    final bodyTextStyle = theme.textTheme.bodySmall!.copyWith(
      color: subTitleColor,
      height: 1.8,
      fontWeight: FontWeight.w400,
    );

    // Pre-compute dialog background color
    final dialogBackgroundColor = isDarkMode ? theme.cardColor : Colors.white;

    // Pre-compute dialog decoration
    final dialogDecoration = BoxDecoration(borderRadius: radius10);

    return Dialog(
      insetPadding: _dialogInsetPadding,
      elevation: _dialogElevation,
      backgroundColor: dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: radius20),
      child: Container(
        decoration: dialogDecoration,
        height: 80.percentWidth,
        child: ClipRRect(
          borderRadius: radius12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background placeholder
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 60.percentWidth,
                ),
              ),

              // Icon placeholder
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: _contentPadding,
                  child: const SizedBox.shrink(), // Placeholder for future icon
                ),
              ),

              // Main content
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildDialogContent(
                  context,
                  theme,
                  titleTextStyle,
                  bodyTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extract dialog content to separate method for better organization
  Widget _buildDialogContent(
    BuildContext context,
    ThemeData theme,
    TextStyle titleTextStyle,
    TextStyle bodyTextStyle,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_deleteText, style: titleTextStyle),
        Padding(
          padding: padding15,
          child: Text(
            _warningText,
            textAlign: TextAlign.center,
            style: bodyTextStyle,
          ),
        ),
        gapH15,
        Padding(
          padding: _dialogInsetPadding,
          child: TwoWayActionButton(
            theme: theme,

            submitButtonTitle: _deleteText,
            cancelButtonTitle: _cancelText,
            cancelButtonBgColor: context.color.primaryColor50,
            onCancelButtonTap: () => context.navigatorPop<void>(),
            onSubmitButtonTap: () => _handleDelete(context),
          ),
        ),
        gapH20,
      ],
    );
  }
}
