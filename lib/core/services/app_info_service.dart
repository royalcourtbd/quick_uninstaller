import 'package:quick_uninstaller/core/utility/utility_export.dart';

String? _currentAppVersion;
Future<String> get currentAppVersion async {
  if (_currentAppVersion == null) {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _currentAppVersion = packageInfo.version;
  }
  log('currentAppVersion: $_currentAppVersion');
  return _currentAppVersion!;
}
