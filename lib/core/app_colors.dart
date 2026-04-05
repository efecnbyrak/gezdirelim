import 'package:flutter/material.dart';

/// Gezdirelim Premium UI Color System
/// Clean, minimal SaaS-style palette with high contrast and modern hues.
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E96FC); // Vibrant SaaS Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  static const Color secondary = Color(0xFFF5A623); // Accent Gold
  static const Color accent = Color(0xFF8B5CF6); // Modern Violet

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dark Mode Surface & Backgrounds (Neutral Cool)
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B);    // Slate 800
  static const Color surfaceHighlight = Color(0xFF334155); // Slate 700
  static const Color surfaceBorder = Color(0xFF334155);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000F172A),
      Color(0xFF0F172A),
    ],
  );

  // Soft Shadows (Glassmorphism & Depth)
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    )
  ];
  
  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primary.withOpacity(0.35),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    )
  ];

  // ==========================================
  // DEPRECATED ALIASES (Transition purposes)
  // ==========================================
  static const Color ciniMavisi = primary;
  static const Color osmanliAltini = secondary;
  static const Color mercanKirmizi = error;
  static const Color zumrutYesili = success;
  static const Color eflatun = accent;
  static const Color surfaceLight = surfaceHighlight;
  static const LinearGradient heroGradient = subtleGradient;
}
