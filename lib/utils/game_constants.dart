import 'package:flutter/material.dart';

class GameConstants {
  // Game mechanics
  static const double bulletSpeed = 400.0;
  static const double bulletCooldown = 1.5;
  static const double missileSpeed = 80.0;
  static const double missileSpeedIncrease = 5.0;
  static const double missileSpawnRate = 2.0;
  static const double missileSpawnRateIncrease = 0.1;
  static const double turretRadius = 20.0;
  static const double bulletRadius = 4.0;
  static const double missileRadius = 8.0;
  
  // Visual constants
  static const double explosionDuration = 0.5;
  static const double trailLength = 50.0;
  static const int maxTrailPoints = 10;
  
  // Colors - Neon cyberpunk theme
  static const Color backgroundColor = Color(0xFF0A0A0F);
  static const Color turretColor = Color(0xFF00FFFF);
  static const Color bulletColor = Color(0xFF00FF00);
  static const Color missileColor = Color(0xFFFF0040);
  static const Color explosionColor = Color(0xFFFFAA00);
  static const Color uiColor = Color(0xFF00CCFF);
  static const Color gridColor = Color(0xFF1A1A2E);
  
  // Gradients
  static const LinearGradient turretGradient = LinearGradient(
    colors: [Color(0xFF00FFFF), Color(0xFF0080FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient bulletGradient = LinearGradient(
    colors: [Color(0xFF00FF00), Color(0xFF80FF00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient missileGradient = LinearGradient(
    colors: [Color(0xFFFF0040), Color(0xFFFF4080)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // UI
  static const double buttonHeight = 60.0;
  static const double buttonWidth = 200.0;
  static const double fontSize = 18.0;
  static const double titleFontSize = 48.0;
  
  // Screen boundaries
  static double screenWidth = 0;
  static double screenHeight = 0;
  
  static void updateScreenSize(Size size) {
    screenWidth = size.width;
    screenHeight = size.height;
  }
}