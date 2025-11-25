import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double fixedHeight = MediaQuery.of(context).size.height;

    // Neutral, clean gradient
    final Color topGradient = isDark
        ? const Color(0xFF16191F)   // dark graphite
        : const Color(0xFFF3F3F3);  // light neutral grey

    final Color baseColor = isDark
        ? const Color(0xFF0E0F11)
        : const Color(0xFFFFFFFF);

    // NEUTRAL subtle line colours — no more cyan/blue
    final Color lineColor = isDark
        ? const Color(0xFF8A8A8A)   // soft grey
        : const Color(0xFF9E9E9E);  // light graphite

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topGradient, baseColor],
              stops: const [0.0, 0.6],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: OptimizedHexPainter(
              color: lineColor,
              isDark: isDark,
              screenHeight: fixedHeight,
            ),
          ),
        ),
      ],
    );
  }
}

class OptimizedHexPainter extends CustomPainter {
  final Color color;
  final bool isDark;
  final double screenHeight;

  final math.Random _random = math.Random(42); // static pattern forever

  OptimizedHexPainter({
    required this.color,
    required this.isDark,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint thinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final Paint thickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    const double radius = 32.0;
    final double hexWidth = math.sqrt(3) * radius;
    final double hexHeight = 2 * radius;
    final double yDist = 0.75 * hexHeight;

    int rows = (screenHeight / yDist).ceil();
    int cols = (size.width / hexWidth).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      double normalizedY = (row * yDist) / screenHeight;

      if (normalizedY > 0.55) break;

      for (int col = 0; col < cols; col++) {
        double xOffset = (row % 2) * (hexWidth / 2);
        double xPos = col * hexWidth + xOffset;
        double yPos = row * yDist;

        double fadeLimit = 0.45;
        double opacity = (1.0 - (normalizedY / fadeLimit)).clamp(0.0, 1.0);

        if (opacity <= 0.01) continue;

        final bool isThick = _random.nextDouble() > 0.85;

        double finalOpacity = isThick
            ? (isDark ? 0.22 : 0.14) * opacity
            : (isDark ? 0.06 : 0.035) * opacity;

        final paint = isThick ? thickPaint : thinPaint;
        paint.color = color.withOpacity(finalOpacity);

        final path = _createHexPath(xPos, yPos, radius);
        canvas.drawPath(path, paint);
      }
    }
  }

  Path _createHexPath(double x, double y, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (60 * i - 30) * (math.pi / 180);
      double px = x + radius * math.cos(angle);
      double py = y + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
