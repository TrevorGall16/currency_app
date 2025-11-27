import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math'; 
import '../utils/currency_utils.dart';
import '../services/api_service.dart';
import '../painters/chart_painter.dart';
import '../widgets/currency_card.dart';
import '../widgets/currency_search_modal.dart';
import '../widgets/time_selector.dart';
import '../widgets/ads_section.dart';
import '../widgets/chart_header.dart';
import '../widgets/app_background.dart'; // <--- NEW IMPORT
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ... [Keep all your existing variables and initState logic exactly as is] ...
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double rate = 0.0; 
  String inputString = "1000"; 
  
  String selectedPeriod = '1M';
  List<double> chartPoints = [];
  List<String> chartLabels = [];
  bool isChartLoading = false;
  DateTime lastUpdated = DateTime.now();

  final List<String> periods = ['5D', '1M', '6M', '1Y', '5Y'];
  final List<String> currencies = [
    'USD', 'EUR', 'THB', 'JPY', 'GBP', 'CNY', 'SGD', 'AUD', 'CAD', 'CHF', 'HKD', 'KRW',
    'INR', 'BRL', 'RUB', 'ZAR', 'MXN', 'TRY', 'NZD', 'SEK'
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedState(initialLoad: true);
    _cleanupOldCachedRates(); // Clean up old cached rates on startup
  }

  /// Cleanup old cached exchange rates to prevent indefinite data accumulation
  /// Removes rates older than 7 days and limits total cached rates to 100
  Future<void> _cleanupOldCachedRates() async {
    final box = Hive.box('settings');
    final now = DateTime.now().millisecondsSinceEpoch;
    final maxAge = const Duration(days: 7).inMilliseconds; // 7-day cache expiration

    // Get all rate cache keys
    final allKeys = box.keys.toList();
    final rateKeys = allKeys.where((key) => key.toString().startsWith('rate_')).toList();

    // Remove old rates based on timestamp
    for (var key in rateKeys) {
      final timestampKey = '${key}_timestamp';
      final timestamp = box.get(timestampKey);

      if (timestamp == null || (now - timestamp) > maxAge) {
        // Delete expired rate
        await box.delete(key);
        await box.delete(timestampKey);
      }
    }

    // Limit total number of cached rates to prevent bloat
    final remainingKeys = box.keys.where((key) => key.toString().startsWith('rate_')).toList();
    if (remainingKeys.length > 100) {
      // Sort by timestamp (most recent first)
      final keyTimestamps = <String, int>{};
      for (var key in remainingKeys) {
        keyTimestamps[key.toString()] = box.get('${key}_timestamp') ?? 0;
      }

      final sortedKeys = keyTimestamps.keys.toList()
        ..sort((a, b) => keyTimestamps[b]!.compareTo(keyTimestamps[a]!));

      // Delete oldest rates (keep only 100 most recent)
      for (var i = 100; i < sortedKeys.length; i++) {
        await box.delete(sortedKeys[i]);
        await box.delete('${sortedKeys[i]}_timestamp');
      }
    }
  }

  void _loadSavedState({bool initialLoad = false}) {
    final box = Hive.box('settings');
    setState(() {
      if (initialLoad) {
        fromCurrency = box.get('fromCurrency') ?? box.get('default_from', defaultValue: 'USD');
      } else {
        String newDefault = box.get('default_from', defaultValue: 'USD');
        if (fromCurrency != newDefault) fromCurrency = newDefault;
      }
      
      toCurrency = box.get('toCurrency', defaultValue: 'EUR');
      inputString = box.get('inputString', defaultValue: "1000");
      
      double? cachedRate = box.get('rate_${fromCurrency}_$toCurrency');
      if (cachedRate != null) rate = cachedRate;
    });
    _updateRate(save: false);
  }

  void _saveState() {
    final box = Hive.box('settings');
    box.put('fromCurrency', fromCurrency);
    box.put('toCurrency', toCurrency);
    box.put('inputString', inputString); 
  }

  String _formatSmart(double value) {
    if (value == 0) return "0.00";
    if (value < 1.0) return value.toStringAsFixed(4);
    return value.toStringAsFixed(2);
  }
  // ... [Keep existing UpdateRate, FetchChartData, etc.] ...

  Future<void> _updateRate({bool save = true}) async {
    final box = Hive.box('settings');
    final cacheKey = 'rate_${fromCurrency}_$toCurrency';
    double? cachedRate = box.get(cacheKey);
    if (cachedRate != null) setState(() => rate = cachedRate);
    else setState(() => rate = CurrencyUtils.getFallbackRate(fromCurrency, toCurrency));
    if (save) _saveState();
    double? liveRate = await ApiService.getRate(fromCurrency, toCurrency);
    if (liveRate != null) {
      if (mounted) { setState(() { rate = liveRate; lastUpdated = DateTime.now(); }); }
      box.put(cacheKey, liveRate);
      // Store timestamp for cache expiration management
      box.put('${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    setState(() => isChartLoading = true);
    final historyData = await ApiService.getHistory(fromCurrency, toCurrency, selectedPeriod);
    List<double> points = [];
    List<String> newLabels = [];
    if (historyData != null && historyData.isNotEmpty) {
      final sortedKeys = historyData.keys.toList()..sort();
      for (var dateStr in sortedKeys) {
        final rateMap = historyData[dateStr] as Map<String, dynamic>;
        points.add((rateMap[toCurrency] as num).toDouble());
      }
      if (points.isNotEmpty) {
         final int count = sortedKeys.length;
         List<int> labelIndices = [0, (count * 0.25).round(), (count * 0.5).round(), (count * 0.75).round(), count - 1];
         labelIndices = labelIndices.toSet().toList()..sort();
         labelIndices = labelIndices.where((i) => i < count).toList();
         for (int i in labelIndices) {
           DateTime d = DateTime.parse(sortedKeys[i]);
           String label = (selectedPeriod == '5Y' || selectedPeriod == '1Y') 
               ? "${d.month.toString().padLeft(2,'0')}/${d.year.toString().substring(2)}" : "${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}";
           newLabels.add(label);
         }
      }
    } else {
      _generateSimulatedChart();
      return;
    }
    if (mounted) setState(() { chartPoints = points; chartLabels = newLabels; isChartLoading = false; });
  }

  void _generateSimulatedChart() {
    final random = Random();
    List<double> points = [];
    List<String> labels = ['Start', 'Mid', 'End'];
    double current = rate > 0 ? rate : 1.0;
    for (int i = 0; i < 20; i++) {
      double change = (random.nextDouble() - 0.5) * 0.01; 
      current = current * (1 + change);
      points.add(current);
    }
    if (mounted) setState(() { chartPoints = points; chartLabels = labels; isChartLoading = false; });
  }

  void _openSearchablePicker(bool isFrom) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.9, expand: false,
        builder: (_, controller) {
          return CurrencySearchModal(
            scrollController: controller, 
            currencies: currencies,
            onSelect: (code) {
              HapticFeedback.lightImpact();
              setState(() {
                if (isFrom) fromCurrency = code; else toCurrency = code;
                final box = Hive.box('settings');
                final cacheKey = 'rate_${fromCurrency}_$toCurrency';
                double? cachedRate = box.get(cacheKey);
                rate = cachedRate ?? CurrencyUtils.getFallbackRate(fromCurrency, toCurrency);
                _updateRate(save: true);
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildSwapButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IconButton(
        icon: const Icon(Icons.swap_vert, color: Color(0xFF1976D2)),
        onPressed: () {
          HapticFeedback.mediumImpact();
          setState(() {
            final temp = fromCurrency; fromCurrency = toCurrency; toCurrency = temp;
            rate = 1 / rate;
            _updateRate(save: true);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double numericInput = double.tryParse(inputString.replaceAll(' ', '')) ?? 0.0;
    double convertedAmount = numericInput * rate;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => _loadSavedState(initialLoad: false));
          },
        ),
        title: Text("Currency Pro", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- CRITICAL FIX: Positioned.fill ensures background is completely static
          // The RepaintBoundary inside AppBackground prevents it from rebuilding
          const Positioned.fill(
            child: AppBackground(),
          ),

          // --- Main Content ---
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight), 
              
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    await _updateRate(save: true);
                  },
                  color: const Color(0xFF10B981),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      children: [
                        CurrencyCard(
                          label: "From",
                          currencyCode: fromCurrency,
                          amount: inputString,
                          isInput: true,
                          onFlagTap: () => _openSearchablePicker(true),
                          onAmountChanged: (val) {
                            setState(() {
                              inputString = val;
                              _saveState();
                            });
                          },
                        ),
                        
                        const SizedBox(height: 4),
                        _buildSwapButton(),
                        const SizedBox(height: 4),

                        GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: _formatSmart(convertedAmount)));
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Copied Result!"), duration: Duration(milliseconds: 800))
                            );
                          },
                          child: CurrencyCard(
                            label: "To",
                            currencyCode: toCurrency,
                            amount: _formatSmart(convertedAmount),
                            isInput: false,
                            onFlagTap: () => _openSearchablePicker(false),
                          ),
                        ),

                        if (!isKeyboardOpen) ...[
                          const SizedBox(height: 20),

                          ChartHeader(
                            fromCurrency: fromCurrency,
                            toCurrency: toCurrency,
                            rate: rate,
                            lastUpdated: lastUpdated,
                            isLive: !chartPoints.isEmpty,
                          ),
                          
                          const SizedBox(height: 12),

                          // Wrap chart in RepaintBoundary for better performance
                          RepaintBoundary(
                            child: SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: isChartLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : CustomPaint(
                                      painter: ChartPainter(
                                        color: const Color(0xFF10B981),
                                        dataPoints: chartPoints,
                                        labels: chartLabels,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          
                          TimeSelector(
                            periods: periods, 
                            selectedPeriod: selectedPeriod, 
                            onPeriodSelected: (p) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                selectedPeriod = p;
                                _fetchChartData();
                              });
                            }
                          ),
                          
                          const SizedBox(height: 20),
                        ] else ...[
                          const SizedBox(height: 10), 
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
                const AdsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Removed GridPainter class (it is now in app_background.dart)