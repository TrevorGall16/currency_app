import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A fully static, visually appealing background that never rebuilds.
/// Wrapped in RepaintBoundary to prevent unnecessary repaints.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Wrap in RepaintBoundary to completely isolate from parent rebuilds
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          // Modern, smooth gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e), // Deep navy blue
                    const Color(0xFF16213e), // Dark blue
                    const Color(0xFF0f3460), // Rich blue
                  ]
                : [
                    const Color(0xFFF0F4F8), // Soft gray-blue
                    const Color(0xFFE8EDF2), // Light blue-gray
                    const Color(0xFFFFFFFF), // Pure white
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        // Optional: Add subtle pattern overlay
        child: CustomPaint(
          painter: ModernPatternPainter(
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

/// Modern, subtle pattern painter with dots/circles for visual interest
/// Only paints once and never repaints due to shouldRepaint returning false
class ModernPatternPainter extends CustomPainter {
  final bool isDark;

  const ModernPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.03)
          : Colors.black.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    // Create a subtle dot pattern
    const double spacing = 60.0;
    const double dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Add slight randomness to make it more organic
        final offsetX = (x ~/ spacing).isEven ? 0.0 : spacing / 2;
        canvas.drawCircle(
          Offset(x + offsetX, y),
          dotRadius,
          paint,
        );
      }
    }

    // Add some subtle circular accents in corners for visual interest
    final accentPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.01)
          : Colors.black.withOpacity(0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Top-left accent
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      size.width * 0.15,
      accentPaint,
    );

    // Bottom-right accent
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.85),
      size.width * 0.2,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ModernPatternPainter oldDelegate) {
    // CRITICAL: Only repaint if theme changes (dark/light mode)
    return isDark != oldDelegate.isDark;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModernPatternPainter && other.isDark == isDark;
  }

  @override
  int get hashCode => isDark.hashCode;
}