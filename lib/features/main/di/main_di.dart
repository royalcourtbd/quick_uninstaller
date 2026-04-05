import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/features/main/data/repositories/main_repository_impl.dart';
import 'package:quick_uninstaller/features/main/domain/repositories/main_repository.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_presenter.dart';

import 'package:get_it/get_it.dart';

class MainDi {
  static Future<void> setup(GetIt serviceLocator) async {
    //  Data Source

    //  Repository
    serviceLocator.registerLazySingleton<MainRepository>(
      () => MainRepositoryImpl(),
    );

    // Use Cases

    // Presenters
    serviceLocator.registerFactory(
      () => loadPresenter(MainPresenter(locate())),
    );
  }
}
