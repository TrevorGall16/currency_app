import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Needed for ImageFilter
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyUtils.getCurrencySymbol(widget.currencyCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get the specific gradient for this currency (e.g. Blue-Yellow for EUR)
    // We will use this for the Border and the Glow
    Gradient flagGradient = CurrencyUtils.getFlagGradient(widget.currencyCode);
    
    // Also get a solid color for the shadow/glow backup
    Color glowColor = CurrencyUtils.getCardColor(widget.currencyCode, isDark);
    if (glowColor == Colors.white || glowColor == const Color(0xFF1C1C1E)) {
      glowColor = isDark ? Colors.blueAccent : Colors.blueGrey;
    }

    // Modern Glass Colors
    Color glassBgColor = isDark 
        ? const Color(0xFF1E293B).withOpacity(0.6) // Darker glass
        : Colors.white.withOpacity(0.7); // Lighter glass

    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.white54 : Colors.black45;
    
    // Input Box Colors
    Color inputBoxColor = isDark 
        ? Colors.black.withOpacity(0.3) 
        : Colors.grey.withOpacity(0.15);

    return Stack(
      children: [
        // 1. The "Glow" Shadow (Behind the card)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                // Colored Ambient Glow
                BoxShadow(
                  color: glowColor.withOpacity(0.25), // Increased opacity for prominence
                  blurRadius: 12, // Big blur for "Atmosphere"
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
                // Deep Shadow for depth
                BoxShadow(
                  color: const Color.fromARGB(73, 0, 0, 0).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),

        // 2. The Glass Card Content
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: glassBgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LABEL ---
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: subTextColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      // --- FLAG PILL ---
                      GestureDetector(
                        onTap: widget.onFlagTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Row(
              children: [
                              Container(
                                // REMOVED SHADOW HERE (Just decoration: null or basic circle)
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  CurrencyUtils.getEmojiFlag(widget.currencyCode), 
                                  style: const TextStyle(fontSize: 24)
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.currencyCode, 
                                style: TextStyle(
                                  fontWeight: FontWeight.w700, 
                                  fontSize: 18, 
                                  color: textColor,
                                  fontFamily: 'Inter',
                                )
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: subTextColor),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // --- INPUT BOX (Now Visible!) ---
                      Expanded(
                        child: Container(
                          height: 56,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: inputBoxColor, // Visible box background
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                          child: widget.isInput
                              ? TextField(
                                  controller: _controller,
                                  onTap: () {
                                    _controller.clear(); 
                                    if (widget.onAmountChanged != null) widget.onAmountChanged!(''); 
                                  },
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 24, // Slightly smaller to fit box nicely
                                    fontWeight: FontWeight.w600, 
                                    color: textColor,
                                    fontFamily: 'Inter',
                                  ),
                                  cursorColor: glowColor,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "0",
                                    hintStyle: TextStyle(color: subTextColor.withOpacity(0.3)),
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    prefixText: "$symbol ", 
                                    prefixStyle: TextStyle(
                                      color: subTextColor, 
                                      fontSize: 24, 
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    String raw = val.replaceAll(' ', '');
                                    if (widget.onAmountChanged != null) widget.onAmountChanged!(raw);
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
                                  textAlign: TextAlign.right,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "$symbol ",
                                        style: TextStyle(
                                          fontSize: 24, 
                                          fontWeight: FontWeight.w400, 
                                          color: subTextColor,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      TextSpan(
                                        text: CurrencyUtils.formatNumber(widget.amount),
                                        style: TextStyle(
                                          fontSize: 24, 
                                          fontWeight: FontWeight.w600, 
                                          color: textColor,
                                          fontFamily: 'Inter',
                                        ),
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
            ),
          ),
        ),

        // 3. The Gradient Border (Painted on top)
        Positioned.fill(
          child: IgnorePointer( // Allow clicks to pass through border
            child: CustomPaint(
              painter: _GradientBorderPainter(
                gradient: flagGradient,
                strokeWidth: 2.0, // Nice visible border
                borderRadius: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- HELPER: PAINTER FOR GRADIENT BORDER ---
class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double borderRadius;

  _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // We adjust the rect so the stroke is centered on the edge
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2, 
      strokeWidth / 2, 
      size.width - strokeWidth, 
      size.height - strokeWidth
    );
    
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect); // Apply the gradient shader

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}