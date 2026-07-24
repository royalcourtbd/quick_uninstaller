import 'package:get_it/get_it.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/features/ads/data/datasource/ad_settings_remote_data_source_impl.dart';
import 'package:quick_uninstaller/features/ads/data/repositories/ad_settings_repository_impl.dart';
import 'package:quick_uninstaller/features/ads/domain/datasource/ad_settings_remote_data_source.dart';
import 'package:quick_uninstaller/features/ads/domain/repositories/ad_settings_repository.dart';
import 'package:quick_uninstaller/features/ads/domain/use_cases/get_banner_ad_config_use_case.dart';
import 'package:quick_uninstaller/features/ads/domain/use_cases/get_interstitial_ad_config_use_case.dart';
import 'package:quick_uninstaller/features/ads/domain/use_cases/get_rewarded_ad_config_use_case.dart';

class AdsDi {
  static Future<void> setup(GetIt serviceLocator) async {
    serviceLocator
      ..registerLazySingleton<AdSettingsRemoteDataSource>(
        () => AdSettingsRemoteDataSourceImpl(locate()),
      )
      ..registerLazySingleton<AdSettingsRepository>(
        () => AdSettingsRepositoryImpl(locate()),
      )
      ..registerLazySingleton<GetBannerAdConfigUseCase>(
        () => GetBannerAdConfigUseCase(locate()),
      )
      ..registerLazySingleton<GetInterstitialAdConfigUseCase>(
        () => GetInterstitialAdConfigUseCase(locate()),
      )
      ..registerLazySingleton<GetRewardedAdConfigUseCase>(
        () => GetRewardedAdConfigUseCase(locate()),
      );
  }
}
