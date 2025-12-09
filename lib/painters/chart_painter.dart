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

    const double textSpace = 30.0;
    final double chartHeight = size.height - textSpace; 

    // --- PAINTS ---
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0 
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Horizontal Grid (Background)
    final horizontalGridPaint = Paint()
      ..color = color.withOpacity(0.05) 
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical Separators (The new "Small Faint Lines")
    final verticalGridPaint = Paint()
      ..color = color.withOpacity(0.08) // Slightly more visible than horizontal
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // --- NORMALIZE DATA ---
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
    final double stepX = size.width / (dataPoints.length - 1);
    
    double drawArea = chartHeight * 0.7; 
    double yPadding = chartHeight * 0.15;

    Offset getPoint(int index) {
      double normalizedY = (dataPoints[index] - minVal) / range;
      double y = chartHeight - (normalizedY * drawArea + yPadding);
      double x = index * stepX;
      return Offset(x, y);
    }

    // --- DRAW CURVED LINE ---
    final path = Path();
    if (dataPoints.length > 1) {
      path.moveTo(getPoint(0).dx, getPoint(0).dy);
      for (int i = 0; i < dataPoints.length - 1; i++) {
        var p0 = getPoint(i);
        var p1 = getPoint(i + 1);
        path.cubicTo(
          (p0.dx + p1.dx) / 2, p0.dy, 
          (p0.dx + p1.dx) / 2, p1.dy, 
          p1.dx, p1.dy
        );
      }
    }

    // --- SHADOW FILL ---
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


    // --- HORIZONTAL REFERENCE LINES ---
    canvas.drawLine(Offset(0, chartHeight * 0.25), Offset(size.width, chartHeight * 0.25), horizontalGridPaint);
    canvas.drawLine(Offset(0, chartHeight * 0.50), Offset(size.width, chartHeight * 0.50), horizontalGridPaint);
    canvas.drawLine(Offset(0, chartHeight * 0.75), Offset(size.width, chartHeight * 0.75), horizontalGridPaint);


    // --- LABELS & VERTICAL SEPARATORS ---
    if (labels.isNotEmpty) {
      // Use all labels passed (since Logic layer already filters them to 5 max)
      for (int i = 0; i < labels.length; i++) {
        double xPos;
        if (labels.length == 1) {
          xPos = size.width / 2;
        } else {
          xPos = (size.width / (labels.length - 1)) * i;
        }

        // 1. Draw the Vertical Separator
        // We draw from top (with padding) down to the axis
        // giving it a "hanging" or "section" feel.
        canvas.drawLine(
          Offset(xPos, 10), // Start slightly below top edge
          Offset(xPos, chartHeight), // Go down to the axis
          verticalGridPaint
        );

        // 2. Draw the Date Text
        _drawText(canvas, labels[i], Offset(xPos, chartHeight + 10));
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withOpacity(0.6), 
        fontSize: 10, 
        fontWeight: FontWeight.w600, 
        fontFamily: 'Inter',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    
    double offsetX = pos.dx - (textPainter.width / 2);
    
    // Prevent cutting off edges
    if (offsetX < 0) offsetX = 4;
    if (offsetX + textPainter.width > canvas.getDestinationClipBounds().width) {
      offsetX = canvas.getDestinationClipBounds().width - textPainter.width - 4;
    }

    textPainter.paint(canvas, Offset(offsetX, pos.dy));
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) => true;
}