import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green.shade100,
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green.shade100,
        ),
        foregroundColor: MaterialStateProperty.all(
          Colors.black,
        ),
      ),
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black,
      ),
    ),
  );
}
