import 'package:flutter/material.dart';
import '../utils/currency_utils.dart';

class ChartHeader extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime lastUpdated;
  final bool isLive; // To show "Live" vs "Cached"

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
    // Format: "2025-11-25"
    final dateStr = "${lastUpdated.year}-${lastUpdated.month.toString().padLeft(2,'0')}-${lastUpdated.day.toString().padLeft(2,'0')}";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
           Text("1 ${CurrencyUtils.getCurrencyName(fromCurrency)} equals", style: TextStyle(color: Colors.grey[600]))
        ]),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(rate.toStringAsFixed(4), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Text(CurrencyUtils.getCurrencyName(toCurrency), style: TextStyle(fontSize: 20, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "Last updated: $dateStr · ", 
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            // Live/Offline Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isLive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isLive ? "Live Data" : "Offline Cache",
                style: TextStyle(
                  color: isLive ? Colors.green : Colors.grey,
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}