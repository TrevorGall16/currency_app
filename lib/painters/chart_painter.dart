import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ChartPainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;
  final List<String> labels;
  // OPTIMIZATION: Pre-calculated values to avoid math in the render loop
  final double minVal;
  final double maxVal;

  ChartPainter({
    required this.color,
    required this.dataPoints,
    required this.labels,
    required this.minVal,
    required this.maxVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Reserve space at bottom for text
    const double textSpace = 24.0;
    final double chartHeight = size.height - textSpace; 

    // 1. Setup Paints
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0 
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gridPaint = Paint()
      ..color = color.withOpacity(0.15) 
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final minorGridPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final tickPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 2. Normalization Logic (OPTIMIZED: Math removed from here)
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final path = Path();
    final double stepX = size.width / (dataPoints.length - 1);

    // 3. Draw Path
    for (int i = 0; i < dataPoints.length; i++) {
      double normalizedY = (dataPoints[i] - minVal) / range;
      double drawArea = chartHeight * 0.8;
      double yPadding = chartHeight * 0.1;
      
      double y = chartHeight - (normalizedY * drawArea + yPadding);
      double x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // 4. Draw Shadow/Gradient
    final Path fillPath = Path.from(path)
      ..lineTo(size.width, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();

    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
    );

    final Paint fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // 5. Draw Grid, Ticks, and Labels
    if (labels.isNotEmpty) {
      int count = labels.length;
      List<double> labelXPositions = [];

      for (int i = 0; i < count; i++) {
        double xPos;
        if (count == 1) {
          xPos = size.width / 2;
        } else {
          xPos = (size.width / (count - 1)) * i;
        }
        labelXPositions.add(xPos);

        canvas.drawLine(Offset(xPos, 0), Offset(xPos, chartHeight), gridPaint);
        canvas.drawLine(Offset(xPos, chartHeight), Offset(xPos, chartHeight + 5), tickPaint);
        _drawText(canvas, labels[i], Offset(xPos, chartHeight + 8));
      }

      for (int i = 0; i < labelXPositions.length - 1; i++) {
        double start = labelXPositions[i];
        double end = labelXPositions[i + 1];
        double mid = (start + end) / 2;

        canvas.drawLine(Offset(mid, chartHeight * 0.4), Offset(mid, chartHeight), minorGridPaint);
        canvas.drawLine(Offset(mid, chartHeight), Offset(mid, chartHeight + 3), minorGridPaint);
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.grey.withOpacity(0.8), 
        fontSize: 10, 
        fontWeight: FontWeight.w500
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    
    double offsetX = pos.dx - (textPainter.width / 2);
    
    if (offsetX < 0) offsetX = 0;
    if (offsetX + textPainter.width > canvas.getDestinationClipBounds().width) {
      offsetX = canvas.getDestinationClipBounds().width - textPainter.width;
    }

    textPainter.paint(canvas, Offset(offsetX, pos.dy));
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    // Only repaint if the bounds or data actually change
    return oldDelegate.minVal != minVal || 
           oldDelegate.maxVal != maxVal ||
           oldDelegate.dataPoints != dataPoints;
  }
}