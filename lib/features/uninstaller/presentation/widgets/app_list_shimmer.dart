import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class AppListShimmer extends StatefulWidget {
  const AppListShimmer({super.key});

  @override
  State<AppListShimmer> createState() => _AppListShimmerState();
}

class _AppListShimmerState extends State<AppListShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return _ShimmerTile(shimmerValue: _animation.value);
          },
        );
      },
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile({required this.shimmerValue});

  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.color.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Icon placeholder
            _shimmerBox(context, width: 48, height: 48, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(context, width: 140, height: 14, radius: 6),
                  const SizedBox(height: 6),
                  _shimmerBox(context, width: 100, height: 11, radius: 5),
                  const SizedBox(height: 4),
                  _shimmerBox(context, width: 120, height: 10, radius: 5),
                ],
              ),
            ),
            _shimmerBox(context, width: 24, height: 24, radius: 12),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(
    BuildContext context, {
    required double width,
    required double height,
    required double radius,
  }) {
    final baseColor = context.color.surfaceColor;
    final highlightColor = context.color.blackColor200;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            (shimmerValue - 0.3).clamp(0.0, 1.0),
            shimmerValue.clamp(0.0, 1.0),
            (shimmerValue + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
