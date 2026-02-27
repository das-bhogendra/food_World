import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color primary = Color(0xFF6A1B9A);
  static const Color secondary = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);

  // Status colors
  static const Color lostColor = Color(0xFFE53935);
  static const Color foundColor = Color(0xFF43A047);
  static const Color claimedColor = Color(0xFF1E88E5);
  static const Color warning = Color(0xFFFFC107);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);

  // Background / Surface
  static const Color surface = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF5F5F5);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Success color
  static const Color success = Color(0xFF4CAF50);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // <-- Add buttonShadow here -->
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];

  // Gradients
  static Gradient lostGradient = LinearGradient(
    colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient foundGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
