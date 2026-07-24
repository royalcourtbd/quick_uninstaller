import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/core/widgets/presentable_widget_builder.dart';
import 'package:quick_uninstaller/features/support/presentation/presenter/support_presenter.dart';
import 'package:quick_uninstaller/features/support/presentation/presenter/support_ui_state.dart';

class DeveloperHelpPage extends StatelessWidget {
  DeveloperHelpPage({super.key});

  final SupportPresenter _presenter = locate<SupportPresenter>();

  @override
  Widget build(BuildContext context) {
    return PresentableWidgetBuilder(
      presenter: _presenter,
      builder: () {
        final state = _presenter.currentUiState;
        return Scaffold(
          backgroundColor: context.color.scaffoldBackgroundColor,
          appBar: AppBar(title: const Text('Developer Help')),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              children: [
                const _SupportHero(),
                const SizedBox(height: 18),
                _ImpactCard(count: state.adWatchCount),
                const SizedBox(height: 18),
                _WatchCard(
                  state: state,
                  onWatch: _presenter.onWatchVideoAdClicked,
                ),
                const SizedBox(height: 18),
                const _PrivacyNote(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SupportHero extends StatelessWidget {
  const _SupportHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.color.cardColor,
            context.color.accentColor.withOpacityPercent(12),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: context.color.accentColor.withOpacityPercent(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityPercent(24),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [context.color.accentColor, context.color.warningColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: context.color.accentColor.withOpacityPercent(28),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 36,
              color: context.color.scaffoldBackgroundColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Keep Quick Uninstaller free',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.color.titleColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quick Uninstaller has no paid features. Watching one short '
            'video ad directly supports future updates, maintenance and '
            'new features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.color.bodyColor,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.color.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.color.surfaceColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.color.successColor.withOpacityPercent(12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.volunteer_activism_rounded,
              color: context.color.successColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 0
                      ? 'Your support makes a difference'
                      : 'You have supported $count '
                            '${count == 1 ? 'time' : 'times'}',
                  style: TextStyle(
                    color: context.color.titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count == 0
                      ? 'Your completed views will appear here.'
                      : 'Thank you for helping the app grow.',
                  style: TextStyle(
                    color: context.color.subTitleColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: context.color.accentColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchCard extends StatelessWidget {
  const _WatchCard({required this.state, required this.onWatch});

  final SupportUiState state;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    final isEnabled = state.isAdAvailable && !state.isRewardedAdLoading;
    final statusColor = !state.isAdAvailable
        ? context.color.errorColor
        : state.isRewardedAdLoaded
        ? context.color.successColor
        : context.color.accentColor;
    final statusText = !state.isAdAvailable
        ? 'Video support is currently unavailable'
        : state.isRewardedAdLoading
        ? 'Preparing your video…'
        : state.isRewardedAdLoaded
        ? 'Video is ready to watch'
        : 'Tap below to load a short video';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.color.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.color.accentColor.withOpacityPercent(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.color.accentColor.withOpacityPercent(12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.smart_display_rounded,
                  color: context.color.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Watch & support',
                  style: TextStyle(
                    color: context.color.titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: context.color.subTitleColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onWatch : null,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                height: 58,
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? LinearGradient(
                          colors: [
                            context.color.accentColor,
                            context.color.warningColor,
                          ],
                        )
                      : null,
                  color: isEnabled ? null : context.color.disableColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isRewardedAdLoading)
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: context.color.whiteColor,
                        ),
                      )
                    else
                      Icon(
                        Icons.play_circle_fill_rounded,
                        color: context.color.scaffoldBackgroundColor,
                        size: 28,
                      ),
                    const SizedBox(width: 10),
                    Text(
                      state.isRewardedAdLoading
                          ? 'Loading video…'
                          : 'Watch a video ad',
                      style: TextStyle(
                        color: isEnabled
                            ? context.color.scaffoldBackgroundColor
                            : context.color.subTitleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: context.color.captionColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Watching is completely optional. Your support count increases '
            'only after the ad confirms a completed view.',
            style: TextStyle(
              color: context.color.captionColor,
              fontSize: 11,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}
