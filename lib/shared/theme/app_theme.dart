import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0EA5E9);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimaryColor = Color(0xFF0F172A);
  static const Color textSecondaryColor = Color(0xFF475569);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: textPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: textSecondaryColor),
      ),
    );
  }
}