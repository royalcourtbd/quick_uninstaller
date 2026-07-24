import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/config/app_color.dart';
import 'package:quick_uninstaller/core/services/launcher_service.dart';
import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';

class AppUpdateBottomSheet extends StatelessWidget {
  const AppUpdateBottomSheet({
    super.key,
    required this.config,
    required this.isForceUpdate,
  });

  final AppUpdateConfigEntity config;
  final bool isForceUpdate;

  static Future<void> show({
    required BuildContext context,
    required AppUpdateConfigEntity config,
    required bool isForceUpdate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: !isForceUpdate,
      enableDrag: !isForceUpdate,
      backgroundColor: Colors.transparent,
      builder: (_) => PopScope(
        canPop: !isForceUpdate,
        child: AppUpdateBottomSheet(
          config: config,
          isForceUpdate: isForceUpdate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.neutralColor300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColor.surfaceLightColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: AppColor.whiteColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColor.titleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version ${config.latestVersion}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColor.subTitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isForceUpdate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.warningColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Required',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColor.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _plainChangeLogs(config.changeLogs),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColor.bodyColor,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isForceUpdate)
                FilledButton.icon(
                  onPressed: _openStore,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Update now'),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Later'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _openStore,
                        child: const Text('Update now'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() {
    final remoteStoreUrl = config.storeUrl.trim();
    return openUrl(
      url: remoteStoreUrl.isEmpty ? playStoreUrl : remoteStoreUrl,
      fallbackUrl: playStoreUrl,
    );
  }

  static String _plainChangeLogs(String source) {
    if (source.trim().isEmpty) {
      return 'Update now to get the latest improvements and fixes.';
    }

    var text = source
        .replaceAll(RegExp(r'<\s*li\b[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'<\s*/\s*li\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\s*/\s*p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    text = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n\n');
    return text.isEmpty
        ? 'Update now to get the latest improvements and fixes.'
        : text;
  }
}
