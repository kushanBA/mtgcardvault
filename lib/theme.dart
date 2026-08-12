import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium "trust + wealth" design system.
/// Obsidian-navy ground (banking trust), champagne gold reserved for money
/// moments (luxury scarcity), market green/red per trading-app convention.
class AppColors {
  final Color bg;
  final Color panel;
  final Color ink;
  final Color ink2;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentBg;
  final Color up;
  final Color down;
  final Color warnBg;
  final Color warnInk;

  const AppColors({
    required this.bg,
    required this.panel,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentBg,
    required this.up,
    required this.down,
    required this.warnBg,
    required this.warnInk,
  });
}

const light = AppColors(
  bg: Color(0xFF0B1017),
  panel: Color(0xFF141B28),
  ink: Color(0xFFEDF1F7),
  ink2: Color(0xFF9AA6B7),
  muted: Color(0xFF6E7A8C),
  line: Color(0xFF22293A),
  accent: Color(0xFFE3B341),
  accentBg: Color(0x21E3B341),
  up: Color(0xFF2BD48A),
  down: Color(0xFFF0544F),
  warnBg: Color(0x21E3B341),
  warnInk: Color(0xFFE3B341),
);

/// Binders tab — same family, slightly deeper ground so the portfolio feels like a vault
const exchange = AppColors(
  bg: Color(0xFF080C12),
  panel: Color(0xFF141B28),
  line: Color(0xFF22293A),
  ink: Color(0xFFEDF1F7),
  ink2: Color(0xFF9AA6B7),
  muted: Color(0xFF6E7A8C),
  accent: Color(0xFFE3B341),
  accentBg: Color(0x21E3B341),
  up: Color(0xFF2BD48A),
  down: Color(0xFFF0544F),
  warnBg: Color(0x21E3B341),
  warnInk: Color(0xFFE3B341),
);
const gold = Color(0xFFE3B341);

/// Camera / Rip Mode
class CameraColors {
  final Color bg;
  final Color panel;
  final Color ink;
  final Color muted;
  final Color detect;
  final Color gold;
  const CameraColors({
    required this.bg,
    required this.panel,
    required this.ink,
    required this.muted,
    required this.detect,
    required this.gold,
  });
}

const cameraTheme = CameraColors(
  bg: Color(0xFF080C12),
  panel: Color(0xFF141B28),
  ink: Color(0xFFEDF1F7),
  muted: Color(0xFF6E7A8C),
  detect: Color(0xFF2BD48A),
  gold: Color(0xFFE3B341),
);

/// Type system: Sora = brand/display voice, Manrope = UI + numbers
/// (true tabular figures so prices don't jiggle as they tick).
TextStyle fontDisplay({double? fontSize, Color? color}) =>
    GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: fontSize, color: color);
TextStyle fontHeavy({double? fontSize, Color? color}) =>
    GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: fontSize, color: color, fontFeatures: const [FontFeature.tabularFigures()]);
TextStyle fontSemi({double? fontSize, Color? color}) =>
    GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: fontSize, color: color);
TextStyle fontBody({double? fontSize, Color? color}) =>
    GoogleFonts.manrope(fontWeight: FontWeight.w400, fontSize: fontSize, color: color);
