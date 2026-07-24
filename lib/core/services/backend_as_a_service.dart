import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:quick_uninstaller/core/models/device_info_model.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/core/utility/trial_utility.dart';
import 'package:synchronized/synchronized.dart';

/// By separating the Firebase code into its own class, we can make it easier to
/// replace Firebase with another backend-as-a-service provider in the future.
///
/// This is because the rest of the app only depends on the public interface of
/// the `BackendAsAService` class, and not on the specific implementation details
/// of Firebase.
/// Therefore, if we decide to switch to a different backend-as-a-service
/// provider, we can simply create a new class that implements the same public
/// interface and use that instead.
///
/// This can help improve the flexibility of the app and make it easier to adapt
/// to changing business requirements or market conditions.
/// It also reduces the risk of vendor lock-in, since we are not tightly
/// coupling our app to a specific backend-as-a-service provider.
///
/// Overall, separating Firebase code into its own class can help make our app
/// more future-proof and adaptable to changing needs.
class BackendAsAService {
  BackendAsAService() {
    _initAnalytics();
  }
  late final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  late final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final Lock _listenToDeviceTokenLock = Lock();
  String? _inMemoryDeviceToken;
  StreamSubscription<String>? _tokenRefreshSubscription;

  static const String noticeCollection = 'notice';
  static const String noticeDoc = 'notice-bn';
  static const String settingsCollection = 'settings';
  static const String appUpdateDoc = 'app_update';
  static const String deviceTokensCollection = 'device_tokens';
  static const String deviceInfoCollection = 'device_info';
  static const String isActive = 'is_active';
  static const String configCollection = 'config';
  static const String adUnitsDoc = 'ad_units';

  void _initAnalytics() {
    catchVoid(() {
      _analytics
          .setAnalyticsCollectionEnabled(true)
          .then((_) => _analytics.logAppOpen());
    });
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await catchFutureOrVoid(() async {
      await _analytics.logEvent(name: name, parameters: parameters);
    });
  }

  Future<void> getRemoteNotice({
    required void Function(Map<String, Object?>) onNotification,
  }) async {
    await catchFutureOrVoid(() async {
      _fireStore.collection(noticeCollection).doc(noticeDoc).snapshots().listen(
        (docSnapshot) {
          onNotification(docSnapshot.data() ?? {});
        },
      );
    });
  }

  Stream<Map<String, dynamic>?> getAppUpdateConfigStream() {
    return _fireStore
        .collection(settingsCollection)
        .doc(appUpdateDoc)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  Stream<Map<String, dynamic>?> getAdUnitsStream() async* {
    logDebugStatic(
      'Starting Firestore listener: $configCollection/$adUnitsDoc',
      'BackendAsAService',
    );
    await for (final snapshot
        in _fireStore
            .collection(configCollection)
            .doc(adUnitsDoc)
            .snapshots()) {
      final data = snapshot.exists ? snapshot.data() : null;
      logDebugStatic(
        'Ad config snapshot received: exists=${snapshot.exists}, data=$data',
        'BackendAsAService',
      );
      yield data;
    }
  }

  Future<void> listenToDeviceToken({
    required FutureOr<void> Function(String) onTokenFound,
  }) async => catchFutureOrVoid(
    () async => await _listenToDeviceToken(onTokenFound: onTokenFound),
  );

  Future<void> _listenToDeviceToken({
    required FutureOr<void> Function(String) onTokenFound,
  }) async {
    await _listenToDeviceTokenLock.synchronized(() async {
      _inMemoryDeviceToken ??= await catchAndReturnFuture<String?>(() {
        return _messaging.getToken();
      });
      logDebug("Device token refreshed -> $_inMemoryDeviceToken");
      final token = _inMemoryDeviceToken;
      if (token != null) await onTokenFound(token);

      _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen((token) {
        _inMemoryDeviceToken = token;
        logDebug("Device token refreshed -> $token");
        unawaited(Future.sync(() => onTokenFound(token)));
      });
    });
  }

  Future<int> storeDeviceInfo(
    DeviceInfoModel deviceInfo, {
    bool incrementWatchVideoCount = false,
  }) async {
    return await catchAndReturnFuture<int>(() async {
          if (deviceInfo.documentId.isEmpty) {
            return deviceInfo.watchVideoCount;
          }

          final docRef = _fireStore
              .collection(deviceInfoCollection)
              .doc(deviceInfo.documentId);
          final legacyDocumentId = deviceInfo.legacyDocumentId;
          final legacyDocRef = legacyDocumentId == null
              ? null
              : _fireStore
                    .collection(deviceInfoCollection)
                    .doc(legacyDocumentId);

          return _fireStore.runTransaction<int>((transaction) async {
            final docSnapshot = await transaction.get(docRef);
            final legacyDocSnapshot = legacyDocRef == null
                ? null
                : await transaction.get(legacyDocRef);

            final currentWatchVideoCount =
                (docSnapshot.data()?[DeviceInfoModel.watchVideoCountKey]
                        as num?)
                    ?.toInt() ??
                0;
            final legacyWatchVideoCount =
                (legacyDocSnapshot?.data()?[DeviceInfoModel.watchVideoCountKey]
                        as num?)
                    ?.toInt() ??
                0;
            final remoteWatchVideoCount =
                currentWatchVideoCount > legacyWatchVideoCount
                ? currentWatchVideoCount
                : legacyWatchVideoCount;
            final syncedWatchVideoCount = incrementWatchVideoCount
                ? remoteWatchVideoCount + 1
                : deviceInfo.watchVideoCount > remoteWatchVideoCount
                ? deviceInfo.watchVideoCount
                : remoteWatchVideoCount;
            final syncedDeviceInfo = deviceInfo.copyWith(
              watchVideoCount: syncedWatchVideoCount,
            );
            final serverTimestamp = FieldValue.serverTimestamp();
            final isNewRewardCompleted =
                incrementWatchVideoCount ||
                deviceInfo.watchVideoCount > remoteWatchVideoCount;
            final lastRewardedAdAt = isNewRewardCompleted
                ? serverTimestamp
                : null;

            if (docSnapshot.exists) {
              transaction.set(
                docRef,
                syncedDeviceInfo.toUpdateJson(
                  updatedAt: serverTimestamp,
                  lastSeenAt: serverTimestamp,
                  lastRewardedAdAt: lastRewardedAdAt,
                ),
                SetOptions(merge: true),
              );
            } else {
              transaction.set(
                docRef,
                syncedDeviceInfo.toCreateJson(
                  createdAt: serverTimestamp,
                  updatedAt: serverTimestamp,
                  lastSeenAt: serverTimestamp,
                  lastRewardedAdAt: lastRewardedAdAt,
                ),
              );
            }

            return syncedWatchVideoCount;
          });
        }) ??
        deviceInfo.watchVideoCount;
  }
}
