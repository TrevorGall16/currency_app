import 'dart:async'; // Added for the Future and async/await logic
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// FIX: Add specific UMP SDK import to resolve "UserMessagingPlatform" errors
import 'package:google_mobile_ads/user_messaging_platform.dart'; 
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // Ensuring debugPrint is available
import 'package:google_fonts/google_fonts.dart'; 
import 'screens/home_screen.dart';

// -------------------------------------------------------------
// This function handles the GDPR/CMP consent flow using the UMP SDK.
// It MUST run before MobileAds.instance.initialize().
// -------------------------------------------------------------
Future<void> _initializeAdMobConsent() async {
  // 1. Request consent information from the user's device
  final consentInformation = await UserMessagingPlatform.instance.requestConsentInfo();

  if (consentInformation.consentStatus == ConsentStatus.required) {
    // 2. Load and show the consent form if required
    final result = await UserMessagingPlatform.instance.loadAndShowConsentForm();
    
    // Check if the user successfully provided consent (or chose limited options)
    if (result.consentStatus == ConsentStatus.notRequired || 
        result.consentStatus == ConsentStatus.obtained) {
      
      debugPrint('Consent obtained. Initializing AdMob.');
      MobileAds.instance.initialize();
      
    } else if (result.consentStatus == ConsentStatus.notObtained) {
      // User declined consent or dismissed the form.
      // This will restrict ads to Non-Personalized.
      debugPrint('Consent not obtained. Initializing AdMob (Non-Personalized).');
      MobileAds.instance.initialize();
    }
  } else {
    // Consent is already obtained or not required (outside EEA/UK).
    debugPrint('Consent not required or already obtained. Initializing AdMob.');
    MobileAds.instance.initialize();
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('settings');
  
  try {
    await Hive.box('settings').compact();
  } catch (e) {
    debugPrint("Compaction failed (harmless): $e");
  }

  // --- NEW: Handle Consent (Mobile only) before initialization ---
  if (!kIsWeb) {
    await _initializeAdMobConsent();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CurrencyApp());
}

class CurrencyApp extends StatefulWidget {
  const CurrencyApp({super.key});

  @override
  State<CurrencyApp> createState() => _CurrencyAppState();
}

class _CurrencyAppState extends State<CurrencyApp> {
  
  @override
  void initState() {
    super.initState();
    // It's generally best to request ATT after UMP consent is resolved.
    // We run it here after the app structure is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
  }

  Future<void> initPlugin() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      print("Tracking status: $status");
    } catch (e) {
      print("Tracking error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, widget) {
        // Fallback to system theme if a specific mode hasn't been saved yet.
        final String savedTheme = box.get('theme_mode', defaultValue: 'system');
        
        ThemeMode currentThemeMode;
        if (savedTheme == 'dark') {
          currentThemeMode = ThemeMode.dark;
        } else if (savedTheme == 'light') {
          currentThemeMode = ThemeMode.light;
        } else {
          currentThemeMode = ThemeMode.system;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Currency Pro',
          themeMode: currentThemeMode,
          
          // --- LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Matches new background
            primaryColor: Colors.blue,
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
            appBarTheme: const AppBarTheme(
              surfaceTintColor: Colors.transparent, // Removes weird scroll tint
            ),
          ),
          
          // --- DARK THEME ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF020617), // Matches new background
            primaryColor: Colors.blue,
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              surfaceTintColor: Colors.transparent,
            ),
          ),
          
          home: const HomeScreen(),
        );
      },
    );
  }
}