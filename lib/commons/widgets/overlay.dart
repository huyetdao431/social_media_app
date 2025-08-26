import 'package:flutter/material.dart';

class CropOverlay extends StatelessWidget {
  final double aspectRatio;

  const CropOverlay({super.key, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Tính toán kích thước khung crop theo aspect ratio
        double cropWidth = screenWidth;
        double cropHeight = cropWidth / aspectRatio;

        if (cropHeight > screenHeight) {
          cropHeight = screenHeight;
          cropWidth = cropHeight * aspectRatio;
        }

        final dx = (screenWidth - cropWidth) / 2;
        final dy = (screenHeight - cropHeight) / 2;

        return CustomPaint(
          size: Size(screenWidth, screenHeight),
          painter: _CropPainter(
            cropRect: Rect.fromLTWH(dx, dy, cropWidth, cropHeight),
          ),
        );
      },
    );
  }
}

class _CropPainter extends CustomPainter {
  final Rect cropRect;

  _CropPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(200);

    // full màn hình
    final fullRect = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // khung crop
    final cutout = Path()..addRect(cropRect);

    // trừ khung crop ra khỏi fullRect
    final overlay = Path.combine(PathOperation.difference, fullRect, cutout);

    canvas.drawPath(overlay, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
