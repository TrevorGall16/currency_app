import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart'; // REQUIRED IMPORT
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('settings');
  
  try {
    await Hive.box('settings').compact();
  } catch (e) {
    debugPrint("Compaction failed (harmless): $e");
  }

  if (!kIsWeb) {
    MobileAds.instance.initialize();
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
        final bool isDark = box.get('isDark', defaultValue: true);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Currency Pro',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          
          // --- LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Matches new background
            primaryColor: Colors.blue,
            // APPLY GLOBAL PROFESSIONAL FONT
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
            // APPLY GLOBAL PROFESSIONAL FONT
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