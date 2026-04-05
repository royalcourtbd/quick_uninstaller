import 'package:flutter/services.dart';
import 'package:quick_uninstaller/core/external_libs/flutter_toast/toast_utility.dart';
import 'package:quick_uninstaller/core/utility/number_utility.dart';
import 'package:quick_uninstaller/core/utility/trial_utility.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showMessage({String? message}) async {
  if (message == null || message.isEmpty) return;

  ToastUtility.showCustomToast(
    message: message,
    yOffset: 100.0,
    duration: 1000.inMilliseconds,
  );
}

Future<void> copyText({required String text}) async {
  await catchFutureOrVoid(() async {
    if (text.isEmpty) return;
    final ClipboardData clipboardData = ClipboardData(text: text);
    await Clipboard.setData(clipboardData);
  });
}

Future<void> shareText({required String text}) async {
  await catchFutureOrVoid(
    () async => SharePlus.instance.share(ShareParams(text: text)),
  );
}
