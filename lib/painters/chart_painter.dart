import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChartPainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;
  final List<String> labels;

  ChartPainter({
    required this.color,
    required this.dataPoints,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double bottomPadding = 20.0;
    final double chartHeight = size.height - bottomPadding;
    final double width = size.width;

    // --- PAINTS ---
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Faint sub-grid for the "5 days" look
    final subGridPaint = Paint()
      ..color = Colors.grey[200]! // Lighter than main grid
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // --- DRAWING GRID & LABELS ---
    if (labels.isNotEmpty) {
      final textStyle = TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold);
      
      // We calculate the gap between major labels
      final double stepX = width / (labels.length - 1);

      for (int i = 0; i < labels.length; i++) {
        final double x = stepX * i;

        // 1. Draw Major Grid Line (The Month/Day Label)
        canvas.drawLine(Offset(x, 0), Offset(x, chartHeight), gridPaint);

        // 2. Draw Text
        final textSpan = TextSpan(text: labels[i], style: textStyle);
        final textPainter = TextPainter(
          text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center
        );
        textPainter.layout();
        
        double textX = x - (textPainter.width / 2);
        if (i == 0) textX = 0;
        if (i == labels.length - 1) textX = width - textPainter.width;
        
        textPainter.paint(canvas, Offset(textX, size.height - 12));

        // 3. Draw Sub-Grid Lines (Between this label and the next)
        // We add 4 lines to simulate ~5-7 day intervals between months
        if (i < labels.length - 1) {
          int subDivisions = 4; // 4 lines = 5 gaps
          double subStep = stepX / (subDivisions + 1);
          
          for (int j = 1; j <= subDivisions; j++) {
            double subX = x + (subStep * j);
            canvas.drawLine(
              Offset(subX, 0), 
              Offset(subX, chartHeight), 
              subGridPaint // Uses the fainter paint
            );
          }
        }
      }
    }

    // --- DRAWING CHART CURVE ---
    final path = Path();
    double minVal = dataPoints.reduce(math.min);
    double maxVal = dataPoints.reduce(math.max);
    double range = maxVal - minVal;
    if (range == 0) range = 1;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * width;
      final normalizedY = (dataPoints[i] - minVal) / range;
      final y = chartHeight - (normalizedY * chartHeight * 0.8) - (chartHeight * 0.1);

      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(width, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) => 
      oldDelegate.dataPoints != dataPoints || oldDelegate.labels != labels;
}