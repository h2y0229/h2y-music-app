import 'package:flutter/material.dart';

/// 프리미엄 Glassmorphism & 네온 다크 디자인 컬러 토큰
class AppColors {
  AppColors._();

  // 배경 컬러
  static const Color bgDark = Color(0xFF07080D);
  static const Color bgSurface1 = Color(0xFF0D0F18);
  static const Color bgSurface2 = Color(0xFF141724);
  static const Color bgSurface3 = Color(0xFF1C2032);

  // 글래스 베이스 & 보더
  static const Color glassBase = Color(0x99121624); // rgba(18, 22, 36, 0.60)
  static const Color glassCard = Color(0x0AFFFFFF); // rgba(255, 255, 255, 0.04)
  static const Color glassCardHover = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x17FFFFFF); // rgba(255, 255, 255, 0.09)
  static const Color glassBorderBright = Color(0x33FFFFFF);

  // 네온 악센트 컬러
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentCyanDim = Color(0x3300F0FF);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentPurpleDim = Color(0x33A855F7);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // 그라디언트
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, accentPurple, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x0FFFFFFF), Color(0x03FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
