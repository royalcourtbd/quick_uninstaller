import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/native_ad_config_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_tile.dart';
import 'package:quick_uninstaller/shared/components/native_ad_widget.dart';

class AppListView extends StatelessWidget {
  const AppListView({
    super.key,
    required this.apps,
    required this.selectedPackages,
    required this.isSelectionMode,
    required this.hasSearchQuery,
    required this.nativeAdConfig,
    required this.onNativeAdClicked,
    required this.onNativeAdImpression,
    required this.onMoreTap,
    required this.onLongPress,
    required this.onTap,
    required this.onIconNeeded,
  });

  final List<AppInfoEntity> apps;
  final Set<String> selectedPackages;
  final bool isSelectionMode;
  final bool hasSearchQuery;
  final NativeAdConfigEntity? nativeAdConfig;
  final VoidCallback onNativeAdClicked;
  final VoidCallback onNativeAdImpression;
  final void Function(AppInfoEntity app) onMoreTap;
  final void Function(String packageName) onLongPress;
  final void Function(String packageName) onTap;
  final void Function(String packageName) onIconNeeded;

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.android, color: context.color.subTitleColor, size: 72),
            const SizedBox(height: 12),
            Text(
              hasSearchQuery ? 'No apps found' : 'No apps',
              style: TextStyle(
                color: context.color.subTitleColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final nativeConfig = nativeAdConfig;
    final shouldShowNativeAds =
        nativeConfig != null &&
        nativeConfig.isActive &&
        nativeConfig.adUnitId.trim().isNotEmpty;
    final nativeAdCount = shouldShowNativeAds ? apps.length ~/ 5 : 0;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: apps.length + nativeAdCount,
      itemBuilder: (context, index) {
        if (shouldShowNativeAds && index % 6 == 5) {
          return NativeAdWidget(
            key: ValueKey('native-ad-$index'),
            adUnitId: nativeConfig.adUnitId,
            isTestMode: nativeConfig.isTestMode,
            onAdClicked: onNativeAdClicked,
            onAdImpression: onNativeAdImpression,
          );
        }

        final appIndex = shouldShowNativeAds ? index - index ~/ 6 : index;
        final app = apps[appIndex];
        return AppListTile(
          app: app,
          isSelected: selectedPackages.contains(app.packageName),
          isSelectionMode: isSelectionMode,
          onMoreTap: () => onMoreTap(app),
          onLongPress: () => onLongPress(app.packageName),
          onTap: () => onTap(app.packageName),
          onIconNeeded: () => onIconNeeded(app.packageName),
        );
      },
    );
  }
}
