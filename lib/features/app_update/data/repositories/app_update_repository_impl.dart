import 'package:fpdart/fpdart.dart';
import 'package:quick_uninstaller/features/app_update/domain/datasource/app_update_remote_data_source.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';
import 'package:quick_uninstaller/features/app_update/domain/repositories/app_update_repository.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  AppUpdateRepositoryImpl(this._remoteDataSource);

  final AppUpdateRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<String, AppUpdateConfigEntity?>> getAppUpdateConfig() async* {
    try {
      await for (final config in _remoteDataSource.getAppUpdateConfigStream()) {
        yield right(config);
      }
    } catch (error) {
      yield left(error.toString());
    }
  }
}
