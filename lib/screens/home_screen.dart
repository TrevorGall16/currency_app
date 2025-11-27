import 'dart:io'; // Needed for Platform check
import 'dart:async'; // Added for Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import AdMob
import 'dart:math';
import '../utils/currency_utils.dart';
import '../services/api_service.dart';
import '../painters/chart_painter.dart';
import '../widgets/currency_card.dart';
import '../widgets/currency_search_modal.dart';
import '../widgets/time_selector.dart';
import '../widgets/chart_header.dart'; 
import '../widgets/app_background.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  // FIX: Make key static so HomeScreen can remain 'const'
  static final GlobalKey<_HomeContentLayerState> _contentKey = GlobalKey();

  const HomeScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    // Check brightness to set status bar color correctly
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false, // Prevents native flutter resizing
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          // Ensure status bar icons (time, battery) are visible
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
          ),
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ).then((_) {
                  // FIX: Use the static key to reload state
                  _contentKey.currentState?._loadSavedState(initialLoad: false);
                });
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.menu,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          // Professional "Logo" Style Text
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 20, 
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: Platform.isIOS ? 'Courier' : 'Roboto', 
              ),
              children: const [
                TextSpan(
                  text: "CURRENCY",
                  style: TextStyle(
                    fontWeight: FontWeight.w300, // Light/Thin weight
                    letterSpacing: 1.5, 
                  ),
                ),
                TextSpan(
                  text: "PRO",
                  style: TextStyle(
                    fontWeight: FontWeight.w900, // Extra Bold/Black
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const RepaintBoundary(child: AppBackground()),
            // FIX: Pass the static key
            HomeContentLayer(key: _contentKey),
          ],
        ),
      ),
    );
  }
}

class HomeContentLayer extends StatefulWidget {
  const HomeContentLayer({super.key});

  @override
  State<HomeContentLayer> createState() => _HomeContentLayerState();
}

class _HomeContentLayerState extends State<HomeContentLayer> {
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double rate = 0.0;
  String inputString = "1000";

  String selectedPeriod = '1M';
  List<double> chartPoints = [];
  List<String> chartLabels = [];
  // OPTIMIZATION: Store min/max here
  double chartMin = 0.0;
  double chartMax = 1.0;

  bool isChartLoading = false;
  DateTime lastUpdated = DateTime.now();
  
  // OFFLINE STATE TRACKER
  bool _isOffline = false;
  Timer? _offlineRetryTimer;

  // ADMOB STATE
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  // Using Google's Test Ad Units. Replace with your real Unit IDs in production.
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-8732422930809097/2155648792' // Android Test Banner
      : 'cca-app-pub-8732422930809097/2711603444'; // iOS Test Banner

  final List<String> periods = ['5D', '1M', '6M', '1Y', '5Y'];
  final List<String> currencies = [
    'USD', 'EUR', 'THB', 'JPY', 'GBP', 'CNY', 'SGD', 'AUD', 'CAD', 'CHF', 'HKD', 'KRW',
    'INR', 'BRL', 'RUB', 'ZAR', 'MXN', 'TRY', 'NZD', 'SEK'
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedState(initialLoad: true);
    _loadBannerAd();
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

  // Changed to public so Parent Widget can call it via context
  void _loadSavedState({bool initialLoad = false}) {
    final box = Hive.box('settings');
    setState(() {
      if (initialLoad) {
        // Initial load: prefer stored state, fallback to default
        fromCurrency = box.get('fromCurrency') ?? box.get('default_from', defaultValue: 'USD');
      } else {
        // Reloading (e.g. returning from settings): 
        // We check 'fromCurrency' first because settings might have updated it.
        // If not found, check 'default_from'.
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
    
    // Try to get live rate
    double? liveRate = await ApiService.getRate(fromCurrency, toCurrency);
    
    if (liveRate != null) {
      // Success: Online
      if (mounted) {
        setState(() {
          rate = liveRate;
          lastUpdated = DateTime.now();
          _isOffline = false; // Reset offline flag
        });
        // Stop checking if we are back online
        _offlineRetryTimer?.cancel();
        _offlineRetryTimer = null;
      }
      box.put(cacheKey, liveRate);
    } else {
      // Failure: Likely Offline
      if (mounted) {
        setState(() {
          _isOffline = true; // Set offline flag
        });
        
        // Auto-retry every 10 seconds if not already retrying
        if (_offlineRetryTimer == null || !_offlineRetryTimer!.isActive) {
          _offlineRetryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
            // Retry implicitly by calling this function again
            _updateRate(save: false);
          });
        }
      }
    }
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    setState(() => isChartLoading = true);
    // If API fails (e.g. no internet), this returns null or empty
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
          // --- IMPROVED LABEL FORMATTING ---
          if (selectedPeriod == '5Y') {
            label = d.year.toString(); // "2025"
          } else if (selectedPeriod == '1Y') {
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            label = "${months[d.month - 1]} ${d.year.toString().substring(2)}"; // "Nov 25"
          } else {
            label = "${d.day}/${d.month}"; // "26/11"
          }
          newLabels.add(label);
        }
      }
    } 

    if (mounted) {
      setState(() {
        chartPoints = points;
        chartLabels = newLabels;
        // OPTIMIZATION: Calculate Min/Max once here!
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
    return GestureDetector(
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
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: const Icon(Icons.swap_vert, color: Color(0xFF1976D2)),
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

    return GestureDetector(
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
            // FIX: Use full screen height even if keyboard is open.
            // This prevents the "pull down" animation when keyboard closes.
            height: screenHeight, 
            padding: EdgeInsets.only(top: topPadding),
            child: Column(
              // FIX: Always justify with spaceBetween to pin items to edges
              // Top items stay at top. Bottom items stay at bottom.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- SECTION 1: THE CARDS & WARNING (Always Top) ---
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- NEW: OFFLINE WARNING BANNER ---
                    if (_isOffline)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off, size: 14, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text(
                                "Offline • Rates may be slightly inaccurate",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.orange[200] : Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else 
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

                // --- SECTION 2: THE GRAPH & TIME ---
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.wifi_off_rounded, color: Colors.grey.withOpacity(0.5), size: 32),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Connect to Internet to see chart",
                                              style: TextStyle(
                                                color: Colors.grey.withOpacity(0.5), 
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    // OPTIMIZATION: RepaintBoundary + Pre-calculated Min/Max
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

                  // --- SECTION 3: THE AD ---
                  SafeArea(
                    top: false,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      // Minimum height for banner ads to avoid layout shift when loading
                      height: _isAdLoaded ? _bannerAd!.size.height.toDouble() : 50,
                      child: (_isAdLoaded && _bannerAd != null)
                          ? SizedBox(
                              width: _bannerAd!.size.width.toDouble(),
                              height: _bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd!),
                            )
                          // Optional: You can keep the placeholder while loading or show nothing
                          : const SizedBox.shrink(),
                    ),
                  ),
                ] else ...[
                   // When keyboard is open, add a spacer to push cards to top?
                   // No, MainAxisAlignment.spaceBetween with only one child (the cards column)
                   // will put it in the center or top?
                   // Column with spaceBetween and 1 child places it at the start.
                   // So this is perfect.
                   const SizedBox.shrink(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}