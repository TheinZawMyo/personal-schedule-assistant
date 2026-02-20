import 'package:flutter/material.dart';

class AppColors {
  // Common Accents
  static const Color primary = Color(0xFF2979FF);
  static const Color accent = Color(0xFF00BCD4);

  // Backgrounds - Dark
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF252525);

  // Backgrounds - Light
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;

  // Text - Dark
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF757575);

  // Text - Light
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextMuted = Color(0xFF9E9E9E);

  // Categories
  static const Color work = Color(0xFF009688); // Teal
  static const Color personal = Color(0xFF5C6BC0); // Indigo
  static const Color health = Color(0xFFFF5252); // Rose
  static const Color study = Color(0xFFFFAB40); // Amber
  static const Color other = Color(0xFF9E9E9E); // Grey

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return work;
      case 'personal':
        return personal;
      case 'health':
        return health;
      case 'study':
        return study;
      case 'other':
        return other;
      default:
        return other;
    }
  }
}
