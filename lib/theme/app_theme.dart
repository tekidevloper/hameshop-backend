import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6200EE),
        brightness: Brightness.light,
      ),
      fontFamily: GoogleFonts.notoSansEthiopic().fontFamily,
      textTheme: GoogleFonts.notoSansEthiopicTextTheme(),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFBB86FC),
        brightness: Brightness.dark,
      ),
      fontFamily: GoogleFonts.notoSansEthiopic().fontFamily,
      textTheme: GoogleFonts.notoSansEthiopicTextTheme(ThemeData.dark().textTheme),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
