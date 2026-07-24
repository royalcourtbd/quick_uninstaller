import 'package:quick_uninstaller/core/services/backend_as_a_service.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/features/ads/data/models/banner_ad_config_model.dart';
import 'package:quick_uninstaller/features/ads/data/models/interstitial_ad_config_model.dart';
import 'package:quick_uninstaller/features/ads/domain/datasource/ad_settings_remote_data_source.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/interstitial_ad_config_entity.dart';

class AdSettingsRemoteDataSourceImpl implements AdSettingsRemoteDataSource {
  final BackendAsAService _backendService;

  AdSettingsRemoteDataSourceImpl(this._backendService);

  @override
  Stream<BannerAdConfigEntity?> getBannerAdConfigStream() {
    logDebugStatic('Requesting banner config stream', 'AdSettingsDataSource');
    return _backendService
        .getAdUnitsStream()
        .map((data) {
          if (data == null) {
            logDebugStatic(
              'Ad config document is missing',
              'AdSettingsDataSource',
            );
            return null;
          }
          final config = BannerAdConfigModel.fromJson(data);
          logDebugStatic(
            'Banner config parsed: id=${config.adUnitId}, '
                'active=${config.isActive}, testMode=${config.isTestMode}',
            'AdSettingsDataSource',
          );
          return config;
        })
        .handleError((Object error, StackTrace stackTrace) {
          logErrorStatic(
            'Banner config stream failed: $error\n$stackTrace',
            'AdSettingsDataSource',
          );
        });
  }

  @override
  Stream<InterstitialAdConfigEntity?> getInterstitialAdConfigStream() {
    logDebugStatic(
      'Requesting interstitial config stream',
      'AdSettingsDataSource',
    );
    return _backendService
        .getAdUnitsStream()
        .map((data) {
          if (data == null) {
            logDebugStatic(
              'Ad config document is missing; using local interstitial config',
              'AdSettingsDataSource',
            );
            return null;
          }
          final config = InterstitialAdConfigModel.fromJson(data);
          logDebugStatic(
            'Interstitial config parsed: id=${config.adUnitId}, '
                'active=${config.isActive}, testMode=${config.isTestMode}',
            'AdSettingsDataSource',
          );
          return config;
        })
        .handleError((Object error, StackTrace stackTrace) {
          logErrorStatic(
            'Interstitial config stream failed: $error\n$stackTrace',
            'AdSettingsDataSource',
          );
        });
  }
}
