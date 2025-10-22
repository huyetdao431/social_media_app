import 'package:flutter/material.dart';
import 'custom_shimmer.dart';

class CachedImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final bool isVideo;
  final bool hasMany;
  final Color shimmerColor; // màu ánh sáng shimmer
  final Color backgroundColor; // màu nền tĩnh

  const CachedImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.isVideo = false,
    this.hasMany = false,
    this.shimmerColor = const Color(0x22FF3B30), // đỏ nhạt lướt qua
    this.backgroundColor = Colors.black, // nền đen
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.white.withAlpha(212);

    final shimmerGradient = LinearGradient(
      colors: [backgroundColor, shimmerColor, backgroundColor],
      stops: const [0.25, 0.5, 0.75],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
    );

    final child = ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Nền đen
          Container(color: backgroundColor),

          // Hiệu ứng shimmer nhẹ
          CustomShimmer(period: const Duration(milliseconds: 1800), gradient: shimmerGradient, child: Container(color: Colors.transparent)),

          if (isVideo) Center(child: Icon(Icons.play_circle_fill, size: 46, color: iconColor)),

          if (hasMany) Positioned(top: 6, right: 6, child: Icon(Icons.collections, size: 20, color: iconColor)),
        ],
      ),
    );

    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return child;
  }
}
