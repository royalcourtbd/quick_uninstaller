import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';

import 'package:quick_uninstaller/features/app_management/domain/usecase/determine_first_run_use_case.dart';
import 'package:quick_uninstaller/quick_uninstaller.dart';
import 'package:quick_uninstaller/shared/components/error_widgets/error_widget.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
        return ErrorWidgetClass(errorDetails: errorDetails);
      };

      await _initializeApp();
      runApp(QuickUninstaller(isFirstRun: await _checkFirstRun()));
    },
    (error, stackTrace) {
      logErrorStatic('Uncaught error: $error\n$stackTrace', 'main');
    },
  );
}

Future<void> _initializeApp() async {
  //await loadEnv();
  await ServiceLocator.setUp();
}

Future<bool> _checkFirstRun() {
  return locate<DetermineFirstRunUseCase>().execute();
}
