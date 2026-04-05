import 'package:get_it/get_it.dart';
import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/features/uninstaller/data/datasource/uninstaller_local_data_source.dart';
import 'package:quick_uninstaller/features/uninstaller/data/repositories/uninstaller_repository_impl.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/repositories/uninstaller_repository.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/usecase/get_installed_apps_use_case.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_presenter.dart';

class UninstallerDi {
  static Future<void> setup(GetIt serviceLocator) async {
    // Data Source
    serviceLocator.registerLazySingleton<UninstallerLocalDataSource>(
      UninstallerLocalDataSource.new,
    );

    // Repository
    serviceLocator.registerLazySingleton<UninstallerRepository>(
      () => UninstallerRepositoryImpl(locate()),
    );

    // Use Cases
    serviceLocator.registerLazySingleton<GetInstalledAppsUseCase>(
      () => GetInstalledAppsUseCase(locate(), locate()),
    );

    // Presenters
    serviceLocator.registerFactory(
      () => loadPresenter(UninstallerPresenter(locate(), locate())),
    );
  }
}
