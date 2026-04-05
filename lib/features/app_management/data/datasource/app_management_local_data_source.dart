import 'package:quick_uninstaller/core/services/local_cache_service.dart';

class AppManagementLocalDataSource {
  AppManagementLocalDataSource(this._localCacheService);

  final LocalCacheService _localCacheService;

  Future<bool> determineFirstRun() async {
    final bool? firstTime = _localCacheService.getData(
      key: CacheKeys.firstTime,
    );
    return firstTime ?? true;
  }

  Future<void> doneFirstTime() async {
    await _localCacheService.saveData(key: CacheKeys.firstTime, value: false);
  }
}
