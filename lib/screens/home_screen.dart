import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_background.dart';
import 'settings_screen.dart';
import 'home_content.dart'; // Ensure this import points to your logic file

class HomeScreen extends StatelessWidget {
  // Key to access the state of the content layer (to refresh data)
  static final GlobalKey<HomeContentLayerState> _contentKey = GlobalKey();

  const HomeScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
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
        resizeToAvoidBottomInset: false, 
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light, 
          ),
          // --- MENU BUTTON ---
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ).then((_) {
                  // Refresh data when returning from Settings (e.g. if Default Currency changed)
                  _contentKey.currentState?.loadSavedState(initialLoad: false);
                });
              },
              child: Container(
                color: Colors.transparent, // Increases touch target area
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.menu,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          
          // --- NEW GRADIENT TITLE ---
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. "CURRENCY" (Thin & Clean)
              Text(
                "CURRENCY",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w300, // Light weight
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.8),
                ),
              ),
              
              const SizedBox(width: 4),

              // 2. "PRO" (Gradient & Bold)
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF60A5FA), const Color.fromARGB(255, 252, 180, 132)] // Pastel Blue -> Purple (Dark)
                      : [const Color(0xFF2563EB), const Color.fromARGB(255, 237, 225, 58)], // Strong Blue -> Purple (Light)
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 25,
                    fontWeight: FontWeight.w900, // Extra Bold
                    letterSpacing: 1.0,
                    color: Colors.white, // Required for ShaderMask to work
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // --- BODY STACK ---
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. The Background (Liquid Glass)
            const RepaintBoundary(child: AppBackground()),
            
            // 2. The Logic & Content Layer
            HomeContentLayer(key: _contentKey),
          ],
        ),
      ),
    );
  }
}