import 'package:flutter/material.dart';

class ColorTokens {
  ColorTokens._();

  // MTG Mana Colors
  static const Color manaWhite = Color(0xFFF9FAF4);
  static const Color manaBlue = Color(0xFF0E68AB);
  static const Color manaBlack = Color(0xFF150B00);
  static const Color manaRed = Color(0xFFD3202A);
  static const Color manaGreen = Color(0xFF00733E);

  // MTG Mana Colors (lighter variants for dark backgrounds)
  static const Color manaWhiteLight = Color(0xFFF9FAF4);
  static const Color manaBlueLight = Color(0xFF4DA3E0);
  static const Color manaBlackLight = Color(0xFF8A7F75);
  static const Color manaRedLight = Color(0xFFE8606A);
  static const Color manaGreenLight = Color(0xFF3DAA70);

  // Surface colors (dark theme)
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceElevated = Color(0xFF252540);
  static const Color surfaceHighest = Color(0xFF30305A);

  // Gold accent (seed color)
  static const Color gold = Color(0xFFC9A96E);
  static const Color goldLight = Color(0xFFE0CDA0);

  static Color getManaColor(String manaType) {
    switch (manaType) {
      case 'W':
        return manaWhite;
      case 'U':
        return manaBlue;
      case 'B':
        return manaBlack;
      case 'R':
        return manaRed;
      case 'G':
        return manaGreen;
      default:
        return Colors.grey;
    }
  }

  static Color getManaColorLight(String manaType) {
    switch (manaType) {
      case 'W':
        return manaWhiteLight;
      case 'U':
        return manaBlueLight;
      case 'B':
        return manaBlackLight;
      case 'R':
        return manaRedLight;
      case 'G':
        return manaGreenLight;
      default:
        return Colors.grey;
    }
  }
}
