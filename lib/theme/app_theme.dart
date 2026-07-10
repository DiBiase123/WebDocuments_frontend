import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1B1B2F),
      scaffoldBackgroundColor: const Color(0xFF162447),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE43F5A),
        secondary: Color(0xFFF08A5D),
        surface: Color(0xFF1F4068),
        error: Color(0xFFFF6B6B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B1B2F),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFEEEEEE),
        ),
        iconTheme: IconThemeData(color: Color(0xFFE43F5A), size: 36),
        toolbarHeight: 80,
        titleSpacing: 20,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 22, color: Color(0xFFEEEEEE)),
        bodyMedium: TextStyle(fontSize: 20, color: Color(0xFFDDDDDD)),
        bodySmall: TextStyle(fontSize: 18, color: Color(0xFFBBBBBB)),
        titleLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFFEEEEEE),
        ),
        titleMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF08A5D),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE43F5A),
          foregroundColor: const Color(0xFFEEEEEE),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F4068),
        labelStyle: const TextStyle(fontSize: 20, color: Color(0xFFBBBBBB)),
        hintStyle: const TextStyle(fontSize: 20, color: Color(0xFF888888)),
        prefixIconColor: const Color(0xFFF08A5D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE43F5A)),
        ),
      ),
      iconTheme: const IconThemeData(size: 36, color: Color(0xFFF08A5D)),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F4068),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
