import 'package:flutter/material.dart';

class AppColors {
  static const bgDark = Color(0xFF070B14);
  static const bgNavy = Color(0xFF0F172A);
  static const cardDark = Color(0xFF111827);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentCyan = Color(0xFF06B6D4);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF1D4ED8), Color(0xFF0E7490)],
  );

  static const interiorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF312E81), Color(0xFF3B82F6)],
  );

  static const exteriorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF0891B2)],
  );
}
