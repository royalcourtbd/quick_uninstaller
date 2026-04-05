import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

abstract class UninstallerRepository {
  Future<List<AppInfoEntity>> getInstalledApps();
}
