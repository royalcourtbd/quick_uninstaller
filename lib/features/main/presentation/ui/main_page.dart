import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/widgets/presentable_widget_builder.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/ui/uninstaller_page.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_presenter.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_ui_state.dart';
import 'package:quick_uninstaller/features/main/presentation/widgets/double_tap_back_to_exit_app.dart';
import 'package:quick_uninstaller/features/main/presentation/widgets/main_navigation_bar.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});
  final MainPresenter _mainPresenter = locate<MainPresenter>();

  final List<Widget> _pages = <Widget>[
    UninstallerPage(),
    UninstallerPage(),
    UninstallerPage(),
    UninstallerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return DoubleTapBackToExitApp(
      mainPresenter: _mainPresenter,
      child: PresentableWidgetBuilder(
        presenter: _mainPresenter,
        builder: () {
          final MainUiState state = _mainPresenter.currentUiState;
          return Scaffold(
            body: state.selectedBottomNavIndex < _pages.length
                ? _pages[state.selectedBottomNavIndex]
                : _pages[0], // Default to first page if index out of range
            bottomNavigationBar: MainNavigationBar(
              selectedIndex: state.selectedBottomNavIndex,
              onDestinationSelected: (index) {
                if (index == 3) {
                  showMessage(message: 'Coming soon');
                  return;
                }
                _mainPresenter.changeNavigationIndex(index);
              },
            ),
          );
        },
      ),
    );
  }
}
