import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF26A69A);
  static const Color primaryColorLight = Color(0xFF4DB6AC);
  static const Color primaryColorDark = Color(0xFF00766C);
  static const Color accentColor = Color(0xFFFFAB40);
  static const Color textColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color limeGreen = Color(0xFFAED581);

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}