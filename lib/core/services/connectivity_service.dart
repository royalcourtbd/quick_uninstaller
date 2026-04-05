import 'package:quick_uninstaller/core/utility/utility_export.dart';

Future<bool> checkInternetConnection() async {
  final bool? isConnected = await catchAndReturnFuture(() async {
    const String kLookUpUrl = 'www.cloudflare.com';
    final List<InternetAddress> result = await InternetAddress.lookup(
      kLookUpUrl,
    );
    if (result.isEmpty) return false;
    if (result.first.rawAddress.isEmpty) return false;
    return true;
  });
  return isConnected ?? false;
}
