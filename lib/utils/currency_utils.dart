import 'package:flutter/material.dart';

class CurrencyUtils {
  // 1. Flags
  static String getEmojiFlag(String code) {
    switch (code) {
      case 'EUR': return '🇪🇺';
      case 'USD': return '🇺🇸';
      case 'THB': return '🇹🇭';
      case 'JPY': return '🇯🇵';
      case 'GBP': return '🇬🇧';
      case 'CNY': return '🇨🇳';
      case 'SGD': return '🇸🇬';
      case 'AUD': return '🇦🇺';
      case 'CAD': return '🇨🇦';
      case 'CHF': return '🇨🇭';
      case 'HKD': return '🇭🇰';
      case 'KRW': return '🇰🇷';
      case 'INR': return '🇮🇳';
      case 'BRL': return '🇧🇷';
      case 'RUB': return '🇷🇺';
      case 'ZAR': return '🇿🇦';
      case 'MXN': return '🇲🇽';
      case 'TRY': return '🇹🇷';
      case 'NZD': return '🇳🇿';
      case 'SEK': return '🇸🇪';
      default: return '🏳️';
    }
  }

  // 2. Names
  static String getCurrencyName(String code) {
    switch (code) {
      case 'EUR': return 'Euro';
      case 'USD': return 'United States Dollar';
      case 'THB': return 'Thai Baht';
      case 'JPY': return 'Japanese Yen';
      case 'GBP': return 'British Pound';
      case 'CNY': return 'Chinese Yuan';
      case 'SGD': return 'Singapore Dollar';
      case 'AUD': return 'Australian Dollar';
      case 'CAD': return 'Canadian Dollar';
      case 'CHF': return 'Swiss Franc';
      case 'HKD': return 'Hong Kong Dollar';
      case 'KRW': return 'South Korean Won';
      case 'INR': return 'Indian Rupee';
      case 'BRL': return 'Brazilian Real';
      case 'RUB': return 'Russian Ruble';
      case 'ZAR': return 'South African Rand';
      case 'MXN': return 'Mexican Peso';
      case 'TRY': return 'Turkish Lira';
      case 'NZD': return 'New Zealand Dollar';
      case 'SEK': return 'Swedish Krona';
      default: return 'Currency';
    }
  }

  // 3. Offline Fallback Rates
  static double getFallbackRate(String from, String to) {
    Map<String, double> ratesInUSD = {
      'USD': 1.0, 'EUR': 0.92, 'GBP': 0.79, 'JPY': 150.0, 'THB': 36.0,
      'CNY': 7.2, 'SGD': 1.34, 'AUD': 1.52, 'CAD': 1.35, 'CHF': 0.88,
      'HKD': 7.82, 'KRW': 1330.0, 'INR': 83.0, 'BRL': 5.0, 'RUB': 90.0, 
      'ZAR': 19.0, 'MXN': 17.0, 'TRY': 30.0, 'NZD': 1.6, 'SEK': 10.5,
    };
    double fromRate = ratesInUSD[from] ?? 1.0;
    double toRate = ratesInUSD[to] ?? 1.0;
    return toRate / fromRate;
  }

  // 4. Card Background Color (The one causing your error)
  static Color getCardColor(String code, bool isDark) {
    Color defaultColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    switch (code) {
      case 'USD': return const Color(0xFF0D47A1); // Navy Blue
      case 'EUR': return const Color(0xFF1565C0); // Royal Blue
      case 'THB': return const Color(0xFFC62828); // Red
      case 'JPY': return const Color(0xFFB71C1C); // Red
      case 'CNY': return const Color(0xFFD32F2F); // Red
      case 'GBP': return const Color(0xFF283593); // Indigo
      case 'AUD': return const Color(0xFF00695C); // Teal
      case 'CAD': return const Color(0xFFD32F2F); // Red
      case 'CHF': return const Color(0xFFC62828); // Red
      case 'SGD': return const Color(0xFFEF6C00); // Orange
      case 'KRW': return const Color(0xFF1565C0); // Blue
      default: return defaultColor;
    }
  }

  // 5. Flag Gradients
  static LinearGradient getFlagGradient(String code) {
    List<Color> colors;
    switch (code) {
      case 'USD': colors = [const Color(0xFF3C3B6E), const Color(0xFFB22234)]; break;
      case 'EUR': colors = [const Color(0xFF003399), const Color(0xFFFFCC00)]; break;
      case 'GBP': colors = [const Color(0xFF012169), const Color(0xFFC8102E)]; break;
      case 'JPY': colors = [const Color(0xFF757575), const Color(0xFFBC002D)]; break;
      case 'CNY': colors = [const Color(0xFFEE1C25), const Color(0xFFFFFF00)]; break;
      case 'THB': colors = [const Color(0xFFA51931), const Color(0xFF24408E)]; break;
      case 'SGD': colors = [const Color(0xFFEF3340), const Color(0xFF757575)]; break;
      case 'AUD': colors = [const Color(0xFF00008B), const Color(0xFFDE2910)]; break;
      case 'CAD': colors = [const Color(0xFFFF0000), const Color(0xFF757575)]; break;
      case 'CHF': colors = [const Color(0xFFFF0000), const Color(0xFF757575)]; break;
      case 'HKD': colors = [const Color(0xFFDE2910), const Color(0xFF757575)]; break;
      case 'KRW': colors = [const Color(0xFF757575), const Color(0xFFCD2E3A)]; break;
      
      // New Currencies
      case 'INR': colors = [const Color(0xFFFF9933), const Color(0xFF138808)]; break;
      case 'BRL': colors = [const Color(0xFF009C3B), const Color(0xFFFFDF00)]; break;
      case 'RUB': colors = [const Color(0xFF0039A6), const Color(0xFFD52B1E)]; break;
      case 'ZAR': colors = [const Color(0xFF007749), const Color(0xFFFFB81C)]; break;
      case 'MXN': colors = [const Color(0xFF006847), const Color(0xFFCE1126)]; break;
      case 'TRY': colors = [const Color(0xFFE30A17), const Color(0xFF757575)]; break;
      case 'NZD': colors = [const Color(0xFF00247D), const Color(0xFFCC142B)]; break;
      case 'SEK': colors = [const Color(0xFF006AA7), const Color(0xFFFECC00)]; break;

      default: colors = [const Color(0xFF424242), const Color(0xFF212121)];
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  // 6. Currency Symbols
  static String getCurrencySymbol(String code) {
    switch (code) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'CNY': return '¥';
      case 'THB': return '฿';
      case 'SGD': return 'S\$';
      case 'AUD': return 'A\$';
      case 'CAD': return 'C\$';
      case 'CHF': return 'Fr';
      case 'HKD': return 'HK\$';
      case 'KRW': return '₩';
      case 'INR': return '₹';
      case 'BRL': return 'R\$';
      case 'RUB': return '₽';
      case 'ZAR': return 'R';
      case 'MXN': return '\$';
      case 'TRY': return '₺';
      case 'NZD': return 'NZ\$';
      case 'SEK': return 'kr';
      default: return '';
    }
  }

  // 7. Number Formatter (Custom, no intl needed)
  static String formatNumber(String value) {
    if (value.isEmpty) return "";
    String raw = value.replaceAll(' ', '');
    List<String> parts = raw.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? ".${parts[1]}" : "";

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(integerPart[i]);
    }
    return buffer.toString() + decimalPart;
  }
}