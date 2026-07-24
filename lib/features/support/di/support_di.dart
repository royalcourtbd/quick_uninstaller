import 'package:get_it/get_it.dart';
import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/features/support/presentation/presenter/support_presenter.dart';

class SupportDi {
  static Future<void> setup(GetIt serviceLocator) async {
    serviceLocator.registerFactory(
      () => loadPresenter(
        SupportPresenter(locate(), locate(), locate(), locate()),
      ),
    );
  }
}
