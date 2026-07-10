import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final bool isTestMode;
  final AdSize adSize;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdImpression;

  static const int _maxRetryAttempts = 3;

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.isTestMode = false,
    this.adSize = AdSize.banner,
    this.onAdClicked,
    this.onAdImpression,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    logDebugStatic(
      'Banner widget created: productionId=${widget.adUnitId}, '
          'testMode=${widget.isTestMode}, '
          'size=${widget.adSize.width}x${widget.adSize.height}',
      'BannerAdWidget',
    );
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = widget.isTestMode
        ? testBannerAdUnitId
        : widget.adUnitId.trim();
    if (adUnitId.isEmpty) {
      logErrorStatic('BannerAd skipped: ad unit ID is empty', 'BannerAdWidget');
      return;
    }

    logDebugStatic(
      'Loading banner: requestId=$adUnitId, attempt=${_retryAttempt + 1}',
      'BannerAdWidget',
    );

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          logDebugStatic('Banner loaded successfully', 'BannerAdWidget');
          _retryAttempt = 0;
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          logErrorStatic(
            'BannerAd failed to load (attempt ${_retryAttempt + 1}): '
                '${error.message}',
            'BannerAdWidget',
          );
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
            });
            _scheduleRetry();
          }
        },
        onAdImpression: (_) {
          logDebugStatic('Banner impression callback', 'BannerAdWidget');
          widget.onAdImpression?.call();
        },
        onAdClicked: (_) {
          logDebugStatic('Banner click callback', 'BannerAdWidget');
          widget.onAdClicked?.call();
        },
      ),
    )..load();
  }

  void _scheduleRetry() {
    if (_retryAttempt >= BannerAdWidget._maxRetryAttempts) {
      logDebugStatic('Banner retry limit reached', 'BannerAdWidget');
      return;
    }
    final delaySeconds = 1 << _retryAttempt;
    logDebugStatic(
      'Scheduling banner retry in ${delaySeconds}s',
      'BannerAdWidget',
    );
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (mounted) _loadAd();
    });
  }

  @override
  void didUpdateWidget(BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.isTestMode != widget.isTestMode) {
      logDebugStatic(
        'Banner configuration changed; reloading',
        'BannerAdWidget',
      );
      _retryTimer?.cancel();
      _retryAttempt = 0;
      _bannerAd?.dispose();
      _isAdLoaded = false;
      _loadAd();
    }
  }

  @override
  void dispose() {
    logDebugStatic('Disposing banner and retry timer', 'BannerAdWidget');
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
