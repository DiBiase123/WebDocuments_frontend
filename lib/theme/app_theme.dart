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
        titleSpacing: 16,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 24, color: Color(0xFFEEEEEE)),
        bodyMedium: TextStyle(fontSize: 22, color: Color(0xFFDDDDDD)),
        bodySmall: TextStyle(fontSize: 20, color: Color(0xFFBBBBBB)),
        titleLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFEEEEEE),
        ),
        titleMedium: TextStyle(
          fontSize: 28,
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
          borderSide: const BorderSide(color: Color(0xFFF08A5D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
      ),
      iconTheme: const IconThemeData(size: 36, color: Color(0xFFF08A5D)),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F4068),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: const Color(0xFF1F4068),
        headerBackgroundColor: const Color(0xFF1B1B2F),
        headerForegroundColor: const Color(0xFFF08A5D),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF1B1B2F);
          }
          return const Color(0xFFEEEEEE);
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFF08A5D);
          }
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.all(const Color(0xFFF08A5D)),
        todayBackgroundColor: WidgetStateProperty.all(
          const Color(0xFFF08A5D).withAlpha(30),
        ),
        confirmButtonStyle: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(const Color(0xFFF08A5D)),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        cancelButtonStyle: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(const Color(0xFFE43F5A)),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFF08A5D)),
      ),
    );
  }
}
