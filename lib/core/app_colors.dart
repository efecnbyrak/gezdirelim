import 'package:flutter/material.dart';

/// Gezdirelim Kültürel Renk Paleti
/// Türk ve Osmanlı kültüründen ilham alan premium renkler
class AppColors {
  // Arkaplan renkleri
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color surfaceBorder = Color(0xFF30363D);

  // Metin renkleri
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);

  // Kültürel Accent Renkler
  static const Color ciniMavisi = Color(0xFF1E96FC);       // İznik Çini Mavisi - Primary
  static const Color osmanliAltini = Color(0xFFF5A623);     // Osmanlı Altın - Secondary
  static const Color mercanKirmizi = Color(0xFFE74C3C);     // Osmanlı Mercan - Danger
  static const Color zumrutYesili = Color(0xFF2ECC71);      // Zümrüt Yeşil - Success
  static const Color eflatun = Color(0xFF9B59B6);           // Osmanlı Eflatun - Special

  // Gradientlar
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E96FC), Color(0xFF0D6EFD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF5A623), Color(0xFFE8930C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xAA0D1117),
      Color(0xFF0D1117),
    ],
  );

  // Eski isimlerin uyumluluğu
  static const Color textBody = textPrimary;
  static const Color accentCyan = ciniMavisi;
  static const Color accentRed = mercanKirmizi;
}
