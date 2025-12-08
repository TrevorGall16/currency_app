import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; // REQUIRED IMPORT
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  
  try {
    await Hive.box('settings').compact();
  } catch (e) {
    debugPrint("Compaction failed (harmless): $e");
  }

  // Initialize AdMob (Mobile only)
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CurrencyApp());
}

// CHANGED TO STATEFUL WIDGET TO HANDLE POPUP
class CurrencyApp extends StatefulWidget {
  const CurrencyApp({super.key});

  @override
  State<CurrencyApp> createState() => _CurrencyAppState();
}

class _CurrencyAppState extends State<CurrencyApp> {
  
  @override
  void initState() {
    super.initState();
    // Call the popup function when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
  }

  // TRACKING POPUP LOGIC
  Future<void> initPlugin() async {
    // 1. Wait 1 second to ensure the app is fully visible (Fixes Apple Rejection)
    await Future.delayed(const Duration(seconds: 1));

    // 2. Request Permission
    try {
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      print("Tracking status: $status");
    } catch (e) {
      print("Tracking error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Pro',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3F3F3),
        primaryColor: Colors.blue,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0F11),
        primaryColor: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}