import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: Colors.blue,
    backgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        color: Colors.black,
      ),
    ),
  );
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    primarySwatch: Colors.teal,
    backgroundColor: Colors.black,
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
      ),
    ),
  );
}
