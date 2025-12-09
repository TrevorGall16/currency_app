import 'package:flutter/material.dart';

class ChartHeader extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime lastUpdated;
  final bool isLive;

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
    
    // Pro colors
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white54 : Colors.black54;

    String dateStr = "${lastUpdated.day.toString().padLeft(2,'0')}/${lastUpdated.month.toString().padLeft(2,'0')}/${lastUpdated.year}";

    return Column(
      children: [
        // The Rate Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16, // Much smaller and elegant
                color: textColor,
              ),
              children: [
                const TextSpan(text: "1 ", style: TextStyle(fontWeight: FontWeight.w400)),
                TextSpan(text: fromCurrency, style: const TextStyle(fontWeight: FontWeight.w600)),
                const TextSpan(text: " = ", style: TextStyle(color: Colors.grey)),
                TextSpan(
                  text: rate.toStringAsFixed(4), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                ),
                const TextSpan(text: " "),
                TextSpan(text: toCurrency, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 6),

        // Subtle Date Label
        Text(
          "As of $dateStr",
          style: TextStyle(
            color: subTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}