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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center( // Center the selector
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22), // Fully rounded capsule
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true, // Only take needed space
          itemCount: periods.length,
          itemBuilder: (context, index) {
            final p = periods[index];
            final isSelected = p == selectedPeriod;
            
            return GestureDetector(
              onTap: () => onPeriodSelected(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (isDark ? Colors.white.withOpacity(0.2) : Colors.white) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isSelected && !isDark ? [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ] : [],
                ),
                child: Text(
                  p, 
                  style: TextStyle(
                    color: isSelected 
                        ? (isDark ? Colors.white : Colors.black) 
                        : (isDark ? Colors.white38 : Colors.black45),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  )
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}