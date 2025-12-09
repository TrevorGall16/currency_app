import 'package:flutter/material.dart';
import 'dart:ui'; 

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // --- REFINED PALETTE ---
    
    // LIGHT MODE: "Liquid Ice" (Pure White + Cool Blue Glass)
    // DARK MODE: "Midnight Jewel" (Deep Slate + Glowing Indigo)

    final Color baseColor = isDark
        ? const Color(0xFF020617) 
        : const Color(0xFFFFFFFF); // Pure White Base

    final Color blob1Color = isDark
        ? const Color(0xFF1E1B4B).withOpacity(0.5) 
        : const Color(0xFFE0F7FA); // Cyan 50 (Ice)

    final Color blob2Color = isDark
        ? const Color(0xFF4C1D95).withOpacity(0.4) 
        : const Color(0xFFE3F2FD); // Blue 50 (Cool Air)

    final Color blob3Color = isDark
        ? const Color(0xFF064E3B).withOpacity(0.3) 
        : const Color(0xFFF0F9FF); // Sky 50 (Subtle Highlight)

    return Stack(
      children: [
        // 1. Base Layer
        Container(color: baseColor),

        // 2. The Liquid Mesh
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0), 
          child: Stack(
            children: [
              // Top Left
              Positioned(
                top: -100,
                left: -50,
                child: _buildBlob(blob1Color, size.width * 0.9),
              ),

              // Bottom Right
              Positioned(
                bottom: -150,
                right: -50,
                child: _buildBlob(blob2Color, size.width * 1.0),
              ),

              // Center Accent
              Positioned(
                top: size.height * 0.4,
                left: -100,
                child: _buildBlob(blob3Color, size.width * 0.8),
              ),
            ],
          ),
        ),

        // 3. Texture / Polish Overlay
        // Light mode gets a very subtle linear gradient to feel like "Glass"
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark 
                  ? Colors.white.withOpacity(0.02) 
                  : Colors.white.withOpacity(0.8), // Stronger wash for "milky glass"
                isDark
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}