import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Boxes
  await Hive.openBox('settings');
  
  // FIX: Run compaction to keep storage clean
  // This removes "deleted" entries from the physical file so the app stays small
  try {
    await Hive.box('settings').compact();
  } catch (e) {
    debugPrint("Compaction failed (harmless): $e");
  }

  // Initialize AdMob (Mobile only)
  // We do not await this to prevent app freeze on startup
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Pro',
      // MATCHES APP BACKGROUND
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3F3F3),
        primaryColor: Colors.blue,
      ),
      // MATCHES APP BACKGROUND (Dark Graphite)
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