import 'dart:math';

import 'package:flutter/material.dart';

class ColorsManager {
  const ColorsManager();

  static const Color primaryColor = Color.fromARGB(255, 78, 198, 230);
  static Brightness brightness = Brightness.dark;
  static const Color appBack = Color.fromARGB(255, 26, 26, 39);

  // text color
  static const Color textColor = Color.fromARGB(255, 226, 226, 226);
  static const Color secondarytextColor = Color.fromRGBO(163, 162, 189, 1);

  // button color
  static const Color buttonColor1 = Color.fromARGB(255, 78, 198, 230);
  static const Color buttonTextColor1 = Color.fromARGB(255, 32, 32, 44);
  static const Color buttonColor2 = Color.fromARGB(255, 54, 56, 77);
  static const Color buttonTextColor2 = Color.fromARGB(255, 226, 226, 226);

  // card
  static const Color cardBack = Color.fromARGB(255, 32, 32, 44); // Color.fromARGB(255, 44, 46, 68);
  static const Color cardText = Color.fromRGBO(255, 255, 255, 1);
  static const Color cardIconColor = Color.fromRGBO(255, 255, 255, 1);

  // arrow
  static const Color upColor = Color.fromARGB(255, 106, 245, 166);
  static const Color downColor = Color.fromARGB(255, 249, 94, 80);
}

MaterialColor generateMaterialColor({required Color color}) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) => max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) =>
    Color.fromRGBO(tintValue(color.red, factor), tintValue(color.green, factor), tintValue(color.blue, factor), 1);

int shadeValue(int value, double factor) => max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) =>
    Color.fromRGBO(shadeValue(color.red, factor), shadeValue(color.green, factor), shadeValue(color.blue, factor), 1);
