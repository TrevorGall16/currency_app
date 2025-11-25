import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.frankfurter.app';
  static const Duration _timeout = Duration(seconds: 5); // Increased slightly for charts

  // 1. Get Current Rate (Fast)
  static Future<double?> getRate(String from, String to) async {
    if (from == to) return 1.0;
    try {
      final url = Uri.parse('$_baseUrl/latest?from=$from&to=$to');
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['rates'][to] as num).toDouble();
      }
    } catch (e) {
      print("API Error (Rate): $e");
    }
    return null;
  }

  // 2. Get Historical Data (Real Data Only)
  static Future<Map<String, dynamic>?> getHistory(String from, String to, String period) async {
    if (from == to) return null;

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 30));

    // ACCURACY FIX: 
    // Free APIs don't support "Hourly" (1D). 
    // We map '1D' to 'Last 7 Days' so the user sees a REAL trend, not a fake line.
    if (period == '1D' || period == '5D') {
        startDate = now.subtract(const Duration(days: 7)); 
    } else if (period == '1M') {
      startDate = now.subtract(const Duration(days: 30));
    } else if (period == '6M') {
      startDate = now.subtract(const Duration(days: 180));
    } else if (period == '1Y') {
      startDate = now.subtract(const Duration(days: 365));
    } else if (period == '5Y') {
      startDate = now.subtract(const Duration(days: 365 * 5));
    }

    final startStr = "${startDate.year}-${startDate.month.toString().padLeft(2,'0')}-${startDate.day.toString().padLeft(2,'0')}";
    
    try {
      final url = Uri.parse('$_baseUrl/$startStr..?from=$from&to=$to');
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates'];
      }
    } catch (e) {
      print("API Error (History): $e");
    }
    return null;
  }
}