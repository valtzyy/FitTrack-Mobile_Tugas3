import 'package:flutter/material.dart';

// Konfigurasi tema visual aplikasi FitTrack menggunakan Material 3.
// Menggunakan palet warna hijau toska / teal energik yang melambangkan kebugaran dan kesehatan.
class AppTheme {
  // Warna utama (Primary)
  static const Color primaryColor = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF115E59); // Teal 800

  // Warna aksen / sekunder
  static const Color secondaryColor = Color(0xFF0284C7); // Sky blue
  static const Color accentOrange = Color(0xFFF97316); // Energic orange untuk kalori/latihan

  // Warna latar belakang dan kartu
  static const Color scaffoldBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color cardColor = Colors.white;

  // Tema Terang (Light Theme)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,

      // Konfigurasi AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Konfigurasi Card
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1.5,
        shadowColor: Colors.black.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Konfigurasi Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF94A3B8),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Konfigurasi Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: CircleBorder(),
      ),

      // Konfigurasi Input Form
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
