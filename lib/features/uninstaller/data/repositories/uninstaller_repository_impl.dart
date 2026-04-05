import 'package:quick_uninstaller/features/uninstaller/data/datasource/uninstaller_local_data_source.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/repositories/uninstaller_repository.dart';

class UninstallerRepositoryImpl implements UninstallerRepository {
  UninstallerRepositoryImpl(this._localDataSource);

  final UninstallerLocalDataSource _localDataSource;

  @override
  Future<List<AppInfoEntity>> getInstalledApps() {
    return _localDataSource.getInstalledApps();
  }
}
