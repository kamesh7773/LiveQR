import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF59E0B);
  static const Color violet = Color(0xFF7C3AED);
  static const Color magenta = Color(0xFFC026D3);

  /// Brand gradient: headline accent text, primary buttons, the living QR.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, violet, magenta],
    stops: [0, .55, 1],
  );

  /// Light "aurora" page ground and its drifting pastel lights.
  static const Color sky = Color(0xFFF6F5FD);
  static const Color auroraBlue = Color(0xFFBFDBFE);
  static const Color auroraLilac = Color(0xFFDDD6FE);
  static const Color auroraPink = Color(0xFFF5D0FE);
  static const Color phoneFrame = Color(0xFF0B0F22);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF55607A);
  static const Color textHint = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
}
