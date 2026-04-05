import 'package:quick_uninstaller/core/utility/trial_utility.dart';
import 'package:quick_uninstaller/features/app_management/data/datasource/app_management_local_data_source.dart';
import 'package:quick_uninstaller/features/app_management/domain/repositories/app_management_repository.dart';

class AppManagementRepositoryImpl implements AppManagementRepository {
  AppManagementRepositoryImpl(this._appManagementLocalDataSource);

  final AppManagementLocalDataSource _appManagementLocalDataSource;

  @override
  Future<void> doneFirstTime() => _appManagementLocalDataSource.doneFirstTime();

  @override
  Future<bool> determineFirstRun() async {
    final bool? shouldCountAsFirstTime = await catchAndReturnFuture(() async {
      final bool isFirstTime = await _appManagementLocalDataSource
          .determineFirstRun();
      if (isFirstTime) return true;
      return false;
    });

    return shouldCountAsFirstTime ?? true;
  }
}
