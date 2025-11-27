import 'package:flutter/material.dart';

class ChartHeader extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime lastUpdated;
  final bool isLive; // Kept to prevent errors in parent widget, even if unused visually now

  const ChartHeader({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.lastUpdated,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.black87;

    // Simple date formatting helper
    String dateStr = "${lastUpdated.day.toString().padLeft(2,'0')}/${lastUpdated.month.toString().padLeft(2,'0')}/${lastUpdated.year}";

    return Column(
      children: [
        // 1. Main Rate
        Text(
          "1 $fromCurrency = ${rate.toStringAsFixed(4)} $toCurrency",
          style: TextStyle(
            color: color,
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 8),

        // 2. "As of" Date (Replaces the "Live Market Rate" indicator)
        Text(
          "As of $dateStr",
          style: TextStyle(
            color: color.withOpacity(0.4),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}