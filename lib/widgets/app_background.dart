import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // View.of(context) gets the physical screen size to prevent keyboard shifts
    final view = View.of(context);
    final double fixedHeight = view.physicalSize.height / view.devicePixelRatio;
    final double fixedWidth = view.physicalSize.width / view.devicePixelRatio;

    // --- SETTING: BACKGROUND GRADIENT COLORS ---
    final Color topGradient = isDark
        ? const Color(0xFF16191F)   // Dark Mode Top Color
        : const Color(0xFFF3F3F3);  // Light Mode Top Color

    final Color baseColor = isDark
        ? const Color(0xFF0E0F11)   // Dark Mode Bottom Color
        : const Color(0xFFFFFFFF);  // Light Mode Bottom Color

    // --- SETTING: HEXAGON LINE COLOR ---
    final Color lineColor = isDark
        ? const Color(0xFF8A8A8A)   // Dark Mode Line Color
        : const Color(0xFF9E9E9E);  // Light Mode Line Color

    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topGradient, baseColor],
              // --- SETTING: GRADIENT FADE POINT ---
              // 0.6 means the top color fades into the bottom color at 60% down the screen
              stops: const [0.0, 0.75], 
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            size: Size(fixedWidth, fixedHeight),
            painter: OptimizedHexPainter(
              color: lineColor,
              isDark: isDark,
              fixedHeight: fixedHeight, 
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
  final double fixedHeight;

  OptimizedHexPainter({
    required this.color,
    required this.isDark,
    required this.fixedHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- SETTING: LINE THICKNESS ---
    final Paint thinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95; // Thickness of the faint background hexagons

    final Paint thickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5; // Thickness of the random "accent" hexagons

    // --- SETTING: HEXAGON SIZE ---
    // Increase this number (e.g., to 45.0) for larger hexagons
    // Decrease this number (e.g., to 20.0) for smaller, denser hexagons
    const double radius = 39.0; 

    final double hexWidth = math.sqrt(3) * radius;
    final double hexHeight = 2 * radius;
    final double yDist = 0.75 * hexHeight;

    int rows = (fixedHeight / yDist).ceil();
    int cols = (size.width / hexWidth).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      double normalizedY = (row * yDist) / fixedHeight;

      // --- SETTING: VERTICAL CUTOFF ---
      // 0.55 means hexagons stop drawing completely at 55% down the screen.
      // Increase to 0.8 to draw them further down.
      if (normalizedY > 0.75) break; 

      for (int col = 0; col < cols; col++) {
        double xOffset = (row % 2) * (hexWidth / 2);
        double xPos = col * hexWidth + xOffset;
        double yPos = row * yDist;

        // --- SETTING: FADE OUT SPEED ---
        // Controls how quickly they become transparent as they go down.
        // 0.45 means they start fading immediately and vanish around 45% down.
        double fadeLimit = 0.65; 
        double opacity = (1.0 - (normalizedY / fadeLimit)).clamp(0.0, 1.0);

        if (opacity <= 0.01) continue;

        bool isThick = _isThickDeterministic(row, col);

        // --- SETTING: OVERALL OPACITY / VISIBILITY ---
        // These decimals (0.0 to 1.0) control how visible the lines are.
        // Higher = More visible. Lower = More subtle.
        double finalOpacity = isThick
            ? (isDark ? 0.32 : 0.24) * opacity // Bold lines opacity (Dark : Light)
            : (isDark ? 0.09 : 0.095) * opacity; // Thin lines opacity (Dark : Light)

        final paint = isThick ? thickPaint : thinPaint;
        paint.color = color.withOpacity(finalOpacity);

        final path = _createHexPath(xPos, yPos, radius);
        canvas.drawPath(path, paint);
      }
    }
  }

  bool _isThickDeterministic(int row, int col) {
    // This math ensures the pattern is random but stays the same every frame
    int hash = (row * 73 + col * 19) % 100;
    
    // --- SETTING: AMOUNT OF BOLD HEXAGONS (DENSITY) ---
    // hash goes from 0 to 99.
    // > 85 means roughly 15% of hexagons are bold.
    // Lower this number (e.g. > 50) to make MANY MORE bold hexagons.
    // Raise this number (e.g. > 95) to make VERY FEW bold hexagons.
    return hash > 68; 
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
  bool shouldRepaint(covariant OptimizedHexPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.color != color;
  }
}