import 'package:flutter/material.dart';
/// Defines the light theme for the application.
final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromRGBO(16, 20, 94, 1),
    secondary: Color.fromRGBO(16, 20, 94, 1),
    onSecondary: Color.fromRGBO(255, 255, 255, 1),
    tertiary: Color.fromRGBO(0, 102, 255, 1),
    background: Color.fromRGBO(242, 242, 244, 1),
    surface: Color.fromRGBO(255, 255, 255, 1),
    error: Color.fromRGBO(246, 71, 64, 1),
  ),
);

/// Defines the dark theme for the application.
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromRGBO(194, 194, 198, 1),
    secondary: Color.fromRGBO(16, 20, 94, 1),
    onSecondary: Color.fromRGBO(194, 194, 198, 1),
    tertiary: Color.fromRGBO(77, 181, 255, 1),
    background: Color.fromRGBO(44, 44, 49, 1),
    surface: Color.fromRGBO(64, 64, 68, 1),
    error: Color.fromRGBO(255, 116, 111, 1),
  ),
);