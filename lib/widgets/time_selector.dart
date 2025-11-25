import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final List<String> periods;
  final String selectedPeriod;
  final Function(String) onPeriodSelected;

  const TimeSelector({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final p = periods[index];
          final isSelected = p == selectedPeriod;
          return GestureDetector(
            onTap: () => onPeriodSelected(p),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!),
              ),
              child: Text(p, style: TextStyle(
                color: isSelected ? const Color(0xFF1B5E20) : Colors.grey[600],
                fontWeight: FontWeight.bold
              )),
            ),
          );
        },
      ),
    );
  }
}