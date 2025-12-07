import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ChartPainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;
  final List<String> labels;
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

    // Reserve space at the bottom for Text so it doesn't overlap with buttons
    const double textSpace = 24.0;
    final double chartHeight = size.height - textSpace; 

    // --- PAINTS ---
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

    final axisPaint = Paint() // Solid line for X-Axis
      ..color = color.withOpacity(0.4) 
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final minorGridPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final tickPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    final dotPaint = Paint() // Dots for data points
      ..color = color
      ..style = PaintingStyle.fill;

    // --- NORMALIZE & PATH ---
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
    final path = Path();
    final double stepX = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      double normalizedY = (dataPoints[i] - minVal) / range;
      // We map 0..1 to the chartHeight (minus padding)
      double drawArea = chartHeight * 0.8;
      double yPadding = chartHeight * 0.1;
      
      // Flip Y because Canvas (0,0) is top-left
      double y = chartHeight - (normalizedY * drawArea + yPadding);
      double x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Draw Small Dot at each point to improve readability
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }

    // --- DRAW SHADOW ---
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

    // --- DRAW X-AXIS LINE ---
    // Draws a line at the bottom of the chart area
    canvas.drawLine(Offset(0, chartHeight), Offset(size.width, chartHeight), axisPaint);

    // --- GRID & LABELS ---
    if (labels.isNotEmpty) {
      int count = labels.length;
      List<double> labelXPositions = [];

      // -- Draw Major Lines & Text --
      for (int i = 0; i < count; i++) {
        double xPos;
        if (count == 1) {
          xPos = size.width / 2;
        } else {
          xPos = (size.width / (count - 1)) * i;
        }
        labelXPositions.add(xPos);

        // Vertical Grid Line
        canvas.drawLine(Offset(xPos, 0), Offset(xPos, chartHeight), gridPaint);
        
        // Bottom Tick
        canvas.drawLine(Offset(xPos, chartHeight), Offset(xPos, chartHeight + 5), tickPaint);
        
        // Text Label
        _drawText(canvas, labels[i], Offset(xPos, chartHeight + 8));
      }

      // -- Draw Intermediate (Minor) Lines --
      // We draw a line halfway between each major label for better scale
      for (int i = 0; i < labelXPositions.length - 1; i++) {
        double start = labelXPositions[i];
        double end = labelXPositions[i + 1];
        double mid = (start + end) / 2;

        // Minor line: starts at 40% height down to bottom
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
    
    // Center the text horizontally
    double offsetX = pos.dx - (textPainter.width / 2);
    
    // Clamp to edges so text doesn't get cut off
    if (offsetX < 0) offsetX = 0;
    if (offsetX + textPainter.width > canvas.getDestinationClipBounds().width) {
      offsetX = canvas.getDestinationClipBounds().width - textPainter.width;
    }

    textPainter.paint(canvas, Offset(offsetX, pos.dy));
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.minVal != minVal || 
           oldDelegate.maxVal != maxVal ||
           oldDelegate.dataPoints != dataPoints ||
           oldDelegate.labels != labels;
  }
}