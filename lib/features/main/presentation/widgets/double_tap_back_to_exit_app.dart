import 'package:flutter/material.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_presenter.dart';

class DoubleTapBackToExitApp extends StatelessWidget {
  const DoubleTapBackToExitApp({
    required this.child,
    required this.mainPresenter,
    this.onBackPressed,
    super.key,
  });

  final Widget child;
  final MainPresenter mainPresenter;
  final Future<bool> Function()? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await onBackPressed?.call() ?? false) return;
        await mainPresenter.handleBackPress();
      },
      child: child,
    );
  }
}
