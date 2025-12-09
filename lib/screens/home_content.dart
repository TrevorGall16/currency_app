import 'dart:io'; 
import 'dart:async'; 
import 'dart:ui'; // Needed for Glass Blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; 
import 'dart:math';
import '../utils/currency_utils.dart';
import '../services/api_service.dart';
import '../painters/chart_painter.dart';
import '../widgets/currency_card.dart';
import '../widgets/currency_search_modal.dart';
import '../widgets/time_selector.dart';
import '../widgets/chart_header.dart'; 

class HomeContentLayer extends StatefulWidget {
  const HomeContentLayer({super.key});

  @override
  State<HomeContentLayer> createState() => HomeContentLayerState();
}

class HomeContentLayerState extends State<HomeContentLayer> {
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double rate = 0.0;
  String inputString = "1000";

  String selectedPeriod = '1M';
  List<double> chartPoints = [];
  List<String> chartLabels = [];
  double chartMin = 0.0;
  double chartMax = 1.0;

  bool isChartLoading = false;
  DateTime lastUpdated = DateTime.now();
  
  bool _isOffline = false;
  Timer? _offlineRetryTimer;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-8732422930809097/2155648792' 
      : 'ca-app-pub-8732422930809097/2711603444'; 

  final List<String> periods = ['5D', '1M', '6M', '1Y', '5Y'];
  final List<String> currencies = [
    'USD', 'EUR', 'THB', 'JPY', 'GBP', 'CNY', 'SGD', 'AUD', 'CAD', 'CHF', 'HKD', 'KRW',
    'INR', 'BRL', 'RUB', 'ZAR', 'MXN', 'TRY', 'NZD', 'SEK'
  ];

  @override
  void initState() {
    super.initState();
    loadSavedState(initialLoad: true);
    _loadBannerAd();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && chartPoints.isEmpty) {
        _updateRate(save: false);
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _offlineRetryTimer?.cancel();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  void loadSavedState({bool initialLoad = false}) {
    final box = Hive.box('settings');
    setState(() {
      if (initialLoad) {
        fromCurrency = box.get('fromCurrency') ?? box.get('default_from', defaultValue: 'USD');
      } else {
        fromCurrency = box.get('fromCurrency') ?? box.get('default_from', defaultValue: 'USD');
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

  Future<void> _updateRate({bool save = true}) async {
    final box = Hive.box('settings');
    final cacheKey = 'rate_${fromCurrency}_$toCurrency';
    double? cachedRate = box.get(cacheKey);
    if (cachedRate != null) setState(() => rate = cachedRate);
    else setState(() => rate = CurrencyUtils.getFallbackRate(fromCurrency, toCurrency));
    
    if (save) _saveState();
    
    double? liveRate = await ApiService.getRate(fromCurrency, toCurrency);
    
    if (liveRate != null) {
      if (mounted) {
        setState(() {
          rate = liveRate;
          lastUpdated = DateTime.now();
          _isOffline = false; 
        });
        _offlineRetryTimer?.cancel();
        _offlineRetryTimer = null;
      }
      box.put(cacheKey, liveRate);
    } else {
      if (mounted) {
        setState(() {
          _isOffline = true; 
        });
        
        if (_offlineRetryTimer == null || !_offlineRetryTimer!.isActive) {
          _offlineRetryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
            _updateRate(save: false);
          });
        }
      }
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
        List<int> labelIndices = [
          0,
          (count * 0.25).round(),
          (count * 0.5).round(),
          (count * 0.75).round(),
          count - 1
        ];
        labelIndices = labelIndices.toSet().toList()..sort();
        labelIndices = labelIndices.where((i) => i < count).toList();
        for (int i in labelIndices) {
          DateTime d = DateTime.parse(sortedKeys[i]);
          String label;
          if (selectedPeriod == '5Y') {
            label = d.year.toString(); 
          } else if (selectedPeriod == '1Y') {
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            label = "${months[d.month - 1]} ${d.year.toString().substring(2)}"; 
          } else {
            label = "${d.day}/${d.month}"; 
          }
          newLabels.add(label);
        }
      }
    } 

    if (mounted) {
      setState(() {
        chartPoints = points;
        chartLabels = newLabels;
        if (points.isNotEmpty) {
          chartMin = points.reduce(min);
          chartMax = points.reduce(max);
        }
        isChartLoading = false;
      });
    }
  }

  void _openSearchablePicker(bool isFrom) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) {
          return CurrencySearchModal(
            scrollController: controller,
            currencies: currencies,
            onSelect: (code) {
              HapticFeedback.lightImpact();
              setState(() {
                if (isFrom) {
                  fromCurrency = code;
                } else {
                  toCurrency = code;
                }
                final box = Hive.box('settings');
                final cacheKey = 'rate_${fromCurrency}_$toCurrency';
                double? cachedRate = box.get(cacheKey);
                rate = cachedRate ??
                    CurrencyUtils.getFallbackRate(fromCurrency, toCurrency);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            final temp = fromCurrency;
            fromCurrency = toCurrency;
            toCurrency = temp;
            rate = 1 / rate;
            _updateRate(save: true);
          });
        },
        child: ClipOval( 
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.swap_vert_rounded, 
                color: isDark ? Colors.white : Colors.black87,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double numericInput =
        double.tryParse(inputString.replaceAll(' ', '')) ?? 0.0;
    double convertedAmount = numericInput * rate;

    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = bottomInset > 0;
    
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. MAIN CONTENT (The interactive part)
        GestureDetector(
          behavior: HitTestBehavior.opaque, 
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            height: screenHeight,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: screenHeight, 
                padding: EdgeInsets.only(top: topPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // REMOVED OFFLINE WIDGET FROM HERE (It was causing the overflow)
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CurrencyCard(
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
                        ),
                        const SizedBox(height: 4),
                        _buildSwapButton(),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(
                                text: _formatSmart(convertedAmount)));
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Copied Result!"),
                                duration: Duration(milliseconds: 800)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CurrencyCard(
                              label: "To",
                              currencyCode: toCurrency,
                              amount: _formatSmart(convertedAmount),
                              isInput: false,
                              onFlagTap: () => _openSearchablePicker(false),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (!isKeyboardOpen) ...[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ChartHeader(
                                fromCurrency: fromCurrency,
                                toCurrency: toCurrency,
                                rate: rate,
                                lastUpdated: lastUpdated,
                                isLive: !chartPoints.isEmpty,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 150, 
                                width: double.infinity,
                                child: isChartLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : chartPoints.isEmpty
                                        ? Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Retrying connection..."), duration: Duration(milliseconds: 500)),
                                                );
                                                _updateRate(save: false);
                                              },
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.refresh_rounded, color: Colors.grey.withOpacity(0.5), size: 32),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Tap to retry chart",
                                                    style: TextStyle(
                                                      color: Colors.grey.withOpacity(0.5), 
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : RepaintBoundary(
                                            child: CustomPaint(
                                              painter: ChartPainter(
                                                color: const Color(0xFF10B981),
                                                dataPoints: chartPoints,
                                                labels: chartLabels,
                                                minVal: chartMin,
                                                maxVal: chartMax,
                                              ),
                                            ),
                                          ),
                              ),
                              const SizedBox(height: 10),
                              TimeSelector(
                                periods: periods,
                                selectedPeriod: selectedPeriod,
                                onPeriodSelected: (p) {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    selectedPeriod = p;
                                    _fetchChartData();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SafeArea(
                        top: false,
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: _isAdLoaded ? _bannerAd!.size.height.toDouble() : 50,
                          child: (_isAdLoaded && _bannerAd != null)
                              ? SizedBox(
                                  width: _bannerAd!.size.width.toDouble(),
                                  height: _bannerAd!.size.height.toDouble(),
                                  child: AdWidget(ad: _bannerAd!),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ] else ...[
                       const SizedBox.shrink(),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. THE FLOATING OFFLINE INDICATOR (Overlay)
        // Positioned absolute so it doesn't push content down
        if (_isOffline)
          Positioned(
            top: topPadding - 10, // Sits just below the title
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 14, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          "Offline • Rates may be slightly inaccurate",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.orange[200] : Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}