import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE50914);
  static const Color darkBackground = Color(0xFF141414); // True Netflix deep grey/black
  static const Color greyText = Color(0xFFB3B3B3); // Lighter grey for better readability

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryRed,
    scaffoldBackgroundColor: darkBackground,
    textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 40, letterSpacing: 1.2),
      titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      bodyLarge: const TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: const TextStyle(color: greyText, fontSize: 14),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: Colors.white,
      surface: Color(0xFF181818),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: greyText,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 10),
    ),
  );
}
