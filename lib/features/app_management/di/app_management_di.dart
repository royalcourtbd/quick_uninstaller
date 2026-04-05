import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/features/app_management/data/datasource/app_management_local_data_source.dart';
import 'package:quick_uninstaller/features/app_management/data/repositories/app_management_repository_impl.dart';
import 'package:quick_uninstaller/features/app_management/domain/repositories/app_management_repository.dart';
import 'package:quick_uninstaller/features/app_management/domain/usecase/determine_first_run_use_case.dart';
import 'package:quick_uninstaller/features/app_management/domain/usecase/save_first_time_use_case.dart';
import 'package:quick_uninstaller/features/app_management/presentation/presenter/app_management_presenter.dart';

import 'package:get_it/get_it.dart';

class AppManagementDi {
  static Future<void> setup(GetIt serviceLocator) async {
    //  Data Source
    serviceLocator.registerLazySingleton<AppManagementLocalDataSource>(
      () => AppManagementLocalDataSource(locate()),
    );

    //  Repository
    serviceLocator.registerLazySingleton<AppManagementRepository>(
      () => AppManagementRepositoryImpl(locate()),
    );

    // Use Cases
    serviceLocator
      ..registerLazySingleton(
        () => DetermineFirstRunUseCase(locate(), locate()),
      )
      ..registerLazySingleton(() => SaveFirstTimeUseCase(locate(), locate()));
    // Presenters
    serviceLocator.registerFactory(
      () => loadPresenter(AppManagementPresenter()),
    );
  }
}
