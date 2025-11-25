import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/currency_utils.dart';

class CurrencyCard extends StatefulWidget {
  final String label;
  final String currencyCode;
  final String amount;
  final bool isInput;
  final VoidCallback onFlagTap;
  final Function(String)? onAmountChanged;

  const CurrencyCard({
    super.key,
    required this.label,
    required this.currencyCode,
    required this.amount,
    required this.isInput,
    required this.onFlagTap,
    this.onAmountChanged,
  });

  @override
  State<CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<CurrencyCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: CurrencyUtils.formatNumber(widget.amount));
  }

  @override
  void didUpdateWidget(covariant CurrencyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isInput && widget.amount != oldWidget.amount) {
      _controller.text = CurrencyUtils.formatNumber(widget.amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.getCurrencySymbol(widget.currencyCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color cardColor = CurrencyUtils.getCardColor(widget.currencyCode, isDark);
    bool hasColor = cardColor != Colors.white && cardColor != const Color(0xFF1C1C1E);
    Color textColor = hasColor ? Colors.white : (isDark ? Colors.white : Colors.black87);
    Color labelColor = hasColor ? Colors.white70 : Colors.grey[500]!;
    Color inputBgColor = hasColor ? Colors.black.withOpacity(0.2) : (isDark ? Colors.grey[900]! : Colors.grey[50]!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        gradient: CurrencyUtils.getFlagGradient(widget.currencyCode),
        borderRadius: BorderRadius.circular(20), // More rounded for modern look
        // --- NEW: WHITE OUTLINE (Glassmorphism feel) ---
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label.toUpperCase(), 
            style: TextStyle(
              color: labelColor, 
              fontSize: 11, 
              fontWeight: FontWeight.w600, 
              letterSpacing: 1.0
            )
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Flag & Code Pill
              GestureDetector(
                onTap: widget.onFlagTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasColor ? Colors.transparent : Colors.grey[200]!.withOpacity(0.3)
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        CurrencyUtils.getEmojiFlag(widget.currencyCode), 
                        style: const TextStyle(fontSize: 22)
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.currencyCode, 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: labelColor),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Amount Input
              Expanded(
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasColor ? Colors.transparent : Colors.grey[300]!.withOpacity(0.3)
                    ),
                  ),
                  child: widget.isInput
                      ? TextField(
                          controller: _controller,
                          // --- START INSERTING HERE ---
        onTap: () {
          _controller.clear(); // 1. Erase the text
          if (widget.onAmountChanged != null) {
            widget.onAmountChanged!(''); // 2. Update the app state to 0
          }
        },
        // --- STOP INSERTING HERE ---
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "0",
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            // --- CHANGED: Prefix instead of Suffix for consistency ---
                            prefixText: "$symbol ", 
                            prefixStyle: const TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w300),
                          ),
                          onChanged: (val) {
                            String raw = val.replaceAll(' ', '');
                            if (widget.onAmountChanged != null) {
                                widget.onAmountChanged!(raw);
                            }
                            String formatted = CurrencyUtils.formatNumber(raw);
                            if (formatted != val) {
                              _controller.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            }
                          },
                        )
                      : RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              // --- CHANGED: Symbol First ---
                              TextSpan(
                                text: "$symbol ",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: Colors.white70),
                              ),
                              TextSpan(
                                text: CurrencyUtils.formatNumber(widget.amount),
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}