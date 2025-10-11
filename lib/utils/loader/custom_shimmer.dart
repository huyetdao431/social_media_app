import 'package:flutter/material.dart';
import '../../materials/app_colors.dart';

class CustomShimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  final Gradient? gradient;

  const CustomShimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1200),
    this.gradient,
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBaseLight;
    final highlight = isDark ? AppColors.skeletonHighlightDark : AppColors.skeletonHighlightLight;

    final gradient = widget.gradient ??
        LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.1, 0.5, 0.9],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
        );

    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final width = bounds.width;
            final dx = _ctl.value * (width * 2);
            return gradient.createShader(Rect.fromLTWH(-width + dx, 0, width * 3, bounds.height));
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.skeletonBaseDark : AppColors.skeletonBaseLight;

    return CustomShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
