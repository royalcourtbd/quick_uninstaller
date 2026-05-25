import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:quick_uninstaller/core/di/setup/setup_module.dart';
import 'package:quick_uninstaller/core/services/backend_as_a_service.dart';
import 'package:quick_uninstaller/core/services/error_message_handler.dart';
import 'package:quick_uninstaller/core/services/local_cache_service.dart';
import 'package:quick_uninstaller/core/services/time_service.dart';
import 'package:quick_uninstaller/core/utility/trial_utility.dart';
import 'package:quick_uninstaller/firebase_options.dart';

class ServiceSetup implements SetupModule {
  final GetIt _serviceLocator;
  ServiceSetup(this._serviceLocator);

  @override
  Future<void> setup() async {
    await _setUpFirebaseServices();
    _serviceLocator
      ..registerLazySingleton<ErrorMessageHandler>(ErrorMessageHandlerImpl.new)
      ..registerLazySingleton<BackendAsAService>(BackendAsAService.new)
      ..registerLazySingleton<TimeService>(TimeService.new)
      ..registerLazySingleton<LocalCacheService>(LocalCacheService.new);

    // await GetServerKey().getServerKeyToken();
    await LocalCacheService.setUp();
  }

  Future<void> _setUpFirebaseServices() async {
    await catchFutureOrVoid(() async {
      final FirebaseApp? firebaseApp = await catchAndReturnFuture(() async {
        return Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      if (firebaseApp == null) return;
      if (kDebugMode) return;

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: true,
          printDetails: false,
        );
        return true;
      };
    });
  }
}
