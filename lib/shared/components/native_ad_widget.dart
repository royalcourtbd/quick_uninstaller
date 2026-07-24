import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_uninstaller/core/config/app_color.dart';
import 'package:quick_uninstaller/core/static/constants.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({
    super.key,
    required this.adUnitId,
    required this.isTestMode,
    this.onAdClicked,
    this.onAdImpression,
  });

  final String adUnitId;
  final bool isTestMode;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdImpression;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  static const int _maxRetryAttempts = 3;

  NativeAd? _nativeAd;
  Timer? _retryTimer;
  bool _isAdLoaded = false;
  int _retryAttempt = 0;
  int _loadGeneration = 0;

  String get _effectiveAdUnitId => kDebugMode || widget.isTestMode
      ? testNativeAdUnitId
      : widget.adUnitId.trim();

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = _effectiveAdUnitId;
    if (adUnitId.isEmpty) return;

    final requestGeneration = _loadGeneration;
    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (requestGeneration != _loadGeneration) {
            ad.dispose();
            return;
          }
          _retryAttempt = 0;
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (requestGeneration != _loadGeneration) return;
          _nativeAd = null;
          if (mounted) setState(() => _isAdLoaded = false);
          _scheduleRetry();
        },
        onAdClicked: (_) => widget.onAdClicked?.call(),
        onAdImpression: (_) => widget.onAdImpression?.call(),
      ),
      nativeAdOptions: NativeAdOptions(
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        videoOptions: VideoOptions(startMuted: true),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppColor.cardColor,
        cornerRadius: 14,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColor.whiteColor,
          backgroundColor: AppColor.accentOrange,
          size: 13,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColor.titleColor,
          backgroundColor: AppColor.cardColor,
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColor.subTitleColor,
          backgroundColor: AppColor.cardColor,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColor.captionColor,
          backgroundColor: AppColor.cardColor,
          size: 11,
        ),
      ),
    )..load();
  }

  void _scheduleRetry() {
    if (_retryAttempt >= _maxRetryAttempts) return;

    final delaySeconds = 1 << _retryAttempt;
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), _loadAd);
  }

  void _resetAndLoad() {
    _loadGeneration++;
    _retryTimer?.cancel();
    _retryAttempt = 0;
    _nativeAd?.dispose();
    _nativeAd = null;
    _isAdLoaded = false;
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant NativeAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.isTestMode != widget.isTestMode) {
      _resetAndLoad();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nativeAd = _nativeAd;
    if (!_isAdLoaded || nativeAd == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: double.infinity,
          height: 110,
          child: AdWidget(ad: nativeAd),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loadGeneration++;
    _retryTimer?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }
}
