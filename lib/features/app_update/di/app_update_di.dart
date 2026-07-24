import 'package:get_it/get_it.dart';
import 'package:quick_uninstaller/features/app_update/data/datasource/app_update_remote_data_source_impl.dart';
import 'package:quick_uninstaller/features/app_update/data/repositories/app_update_repository_impl.dart';
import 'package:quick_uninstaller/features/app_update/domain/datasource/app_update_remote_data_source.dart';
import 'package:quick_uninstaller/features/app_update/domain/repositories/app_update_repository.dart';
import 'package:quick_uninstaller/features/app_update/domain/use_cases/get_app_update_config_use_case.dart';

class AppUpdateDi {
  static Future<void> setup(GetIt serviceLocator) async {
    serviceLocator
      ..registerLazySingleton<AppUpdateRemoteDataSource>(
        () => AppUpdateRemoteDataSourceImpl(serviceLocator()),
      )
      ..registerLazySingleton<AppUpdateRepository>(
        () => AppUpdateRepositoryImpl(serviceLocator()),
      )
      ..registerLazySingleton<GetAppUpdateConfigUseCase>(
        () => GetAppUpdateConfigUseCase(serviceLocator()),
      );
  }
}
