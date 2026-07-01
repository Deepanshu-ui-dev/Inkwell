import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Extension ──────────────────────────────────────────────────────────
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surface;
  final Color surfaceCard;
  final Color surfaceWhite;
  final Color border;
  final Color divider;
  final Color accent;
  final Color accentDeep;
  final Color accentWarm;
  final Color ink;
  final Color inkSecondary;
  final Color inkMuted;
  final Color inkOnDark;
  final Color error;
  final Color success;
  final Color tagBg;
  final Color tagText;
  final Color heroBg;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceCard,
    required this.surfaceWhite,
    required this.border,
    required this.divider,
    required this.accent,
    required this.accentDeep,
    required this.accentWarm,
    required this.ink,
    required this.inkSecondary,
    required this.inkMuted,
    required this.inkOnDark,
    required this.error,
    required this.success,
    required this.tagBg,
    required this.tagText,
    required this.heroBg,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  @override
  AppColorsExtension copyWith({
    Color? background, Color? surface, Color? surfaceCard,
    Color? surfaceWhite, Color? border, Color? divider,
    Color? accent, Color? accentDeep, Color? accentWarm,
    Color? ink, Color? inkSecondary, Color? inkMuted, Color? inkOnDark,
    Color? error, Color? success, Color? tagBg, Color? tagText,
    Color? heroBg, Color? shimmerBase, Color? shimmerHighlight,
  }) => AppColorsExtension(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceCard: surfaceCard ?? this.surfaceCard,
    surfaceWhite: surfaceWhite ?? this.surfaceWhite,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    accent: accent ?? this.accent,
    accentDeep: accentDeep ?? this.accentDeep,
    accentWarm: accentWarm ?? this.accentWarm,
    ink: ink ?? this.ink,
    inkSecondary: inkSecondary ?? this.inkSecondary,
    inkMuted: inkMuted ?? this.inkMuted,
    inkOnDark: inkOnDark ?? this.inkOnDark,
    error: error ?? this.error,
    success: success ?? this.success,
    tagBg: tagBg ?? this.tagBg,
    tagText: tagText ?? this.tagText,
    heroBg: heroBg ?? this.heroBg,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
  );

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other == null) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceWhite: Color.lerp(surfaceWhite, other.surfaceWhite, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSecondary: Color.lerp(inkSecondary, other.inkSecondary, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkOnDark: Color.lerp(inkOnDark, other.inkOnDark, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      tagBg: Color.lerp(tagBg, other.tagBg, t)!,
      tagText: Color.lerp(tagText, other.tagText, t)!,
      heroBg: Color.lerp(heroBg, other.heroBg, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

// ── Typography Extension ─────────────────────────────────────────────────────
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  final TextStyle hero;
  final TextStyle heroSub;
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle caption;

  const AppTypographyExtension({
    required this.hero,
    required this.heroSub,
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.caption,
  });

  @override
  AppTypographyExtension copyWith({
    TextStyle? hero, TextStyle? heroSub,
    TextStyle? displayLarge, TextStyle? displayMedium, TextStyle? displaySmall,
    TextStyle? titleLarge, TextStyle? titleMedium,
    TextStyle? bodyLarge, TextStyle? bodyMedium, TextStyle? bodySmall,
    TextStyle? labelLarge, TextStyle? caption,
  }) => AppTypographyExtension(
    hero: hero ?? this.hero, heroSub: heroSub ?? this.heroSub,
    displayLarge: displayLarge ?? this.displayLarge,
    displayMedium: displayMedium ?? this.displayMedium,
    displaySmall: displaySmall ?? this.displaySmall,
    titleLarge: titleLarge ?? this.titleLarge,
    titleMedium: titleMedium ?? this.titleMedium,
    bodyLarge: bodyLarge ?? this.bodyLarge,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySmall: bodySmall ?? this.bodySmall,
    labelLarge: labelLarge ?? this.labelLarge,
    caption: caption ?? this.caption,
  );

  @override
  AppTypographyExtension lerp(AppTypographyExtension? other, double t) => this;
}

// ── Context Extensions ───────────────────────────────────────────────────────
extension AppThemeExtension on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
  AppTypographyExtension get typography => Theme.of(this).extension<AppTypographyExtension>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// ── Token Values ─────────────────────────────────────────────────────────────
class _C {
  static const bg         = Color(0xFFF4F0E6);
  static const surface    = Color(0xFFEBE7DC);
  static const card       = Color(0xFFFAF8F3);
  static const white      = Color(0xFFFFFFFF);
  static const border     = Color(0xFFDAD5C8);
  static const divider    = Color(0xFFE4E0D4);
  static const accent     = Color(0xFFC8FF47);
  static const accentDeep = Color(0xFF2E5000);
  static const accentWarm = Color(0xFFFF7A3D);
  static const ink        = Color(0xFF0D0D0B);
  static const ink2       = Color(0xFF585550);
  static const ink3       = Color(0xFF9A9588);
  static const inkDark    = Color(0xFFF4F0E6);
  static const error      = Color(0xFFCF4035);
  static const success    = Color(0xFF278A50);
  static const tagBg      = Color(0xFFE8FAB0);
  static const tagText    = Color(0xFF2E5000);
  static const heroBg     = Color(0xFF0D0D0B);
  static const shimBase   = Color(0xFFE8E4D8);
  static const shimHigh   = Color(0xFFF4F1E8);
}

AppColorsExtension get lightColors => const AppColorsExtension(
  background: _C.bg,       surface: _C.surface,
  surfaceCard: _C.card,    surfaceWhite: _C.white,
  border: _C.border,       divider: _C.divider,
  accent: _C.accent,       accentDeep: _C.accentDeep,
  accentWarm: _C.accentWarm, ink: _C.ink,
  inkSecondary: _C.ink2,   inkMuted: _C.ink3,
  inkOnDark: _C.inkDark,   error: _C.error,
  success: _C.success,     tagBg: _C.tagBg,
  tagText: _C.tagText,     heroBg: _C.heroBg,
  shimmerBase: _C.shimBase, shimmerHighlight: _C.shimHigh,
);

AppTypographyExtension _buildTypography(AppColorsExtension c) => AppTypographyExtension(
  hero: GoogleFonts.instrumentSerif(
    fontSize: 52, fontWeight: FontWeight.w400,
    color: c.inkOnDark, height: 0.96, letterSpacing: -1.5,
  ),
  heroSub: GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: c.inkOnDark.withValues(alpha: 0.6), height: 1.55,
  ),
  displayLarge: GoogleFonts.instrumentSerif(
    fontSize: 36, fontWeight: FontWeight.w400,
    color: c.ink, height: 1.06, letterSpacing: -0.8,
  ),
  displayMedium: GoogleFonts.instrumentSerif(
    fontSize: 26, fontWeight: FontWeight.w400,
    color: c.ink, height: 1.12, letterSpacing: -0.4,
  ),
  displaySmall: GoogleFonts.instrumentSerif(
    fontSize: 21, fontWeight: FontWeight.w400,
    color: c.ink, height: 1.2,
  ),
  titleLarge: GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: c.ink, height: 1.3, letterSpacing: -0.2,
  ),
  titleMedium: GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: c.ink, height: 1.3,
  ),
  bodyLarge: GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w400,
    color: c.ink, height: 1.75,
  ),
  bodyMedium: GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: c.inkSecondary, height: 1.55,
  ),
  bodySmall: GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: c.inkMuted, height: 1.4,
  ),
  labelLarge: GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: c.ink, letterSpacing: 0.1,
  ),
  caption: GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: c.inkMuted, letterSpacing: 1.1,
  ),
);

// ── Dark Color Tokens ─────────────────────────────────────────────────────────
class _DC {
  static const bg         = Color(0xFF0D1117);
  static const surface    = Color(0xFF161B22);
  static const card       = Color(0xFF1C2128);
  static const white      = Color(0xFF21262D);
  static const border     = Color(0xFF30363D);
  static const divider    = Color(0xFF21262D);
  static const accent     = Color(0xFFC8FF47);
  static const accentDeep = Color(0xFF2E5000);
  static const accentWarm = Color(0xFFFF7A3D);
  static const ink        = Color(0xFFE6EDF3);
  static const ink2       = Color(0xFF8B949E);
  static const ink3       = Color(0xFF6E7681);
  static const inkDark    = Color(0xFFE6EDF3);
  static const error      = Color(0xFFFF7B72);
  static const success    = Color(0xFF3FB950);
  static const tagBg      = Color(0xFF1A2E05);
  static const tagText    = Color(0xFFC8FF47);
  static const heroBg     = Color(0xFF0D1117);
  static const shimBase   = Color(0xFF21262D);
  static const shimHigh   = Color(0xFF30363D);
}

AppColorsExtension get darkColors => const AppColorsExtension(
  background: _DC.bg,       surface: _DC.surface,
  surfaceCard: _DC.card,    surfaceWhite: _DC.white,
  border: _DC.border,       divider: _DC.divider,
  accent: _DC.accent,       accentDeep: _DC.accentDeep,
  accentWarm: _DC.accentWarm, ink: _DC.ink,
  inkSecondary: _DC.ink2,   inkMuted: _DC.ink3,
  inkOnDark: _DC.inkDark,   error: _DC.error,
  success: _DC.success,     tagBg: _DC.tagBg,
  tagText: _DC.tagText,     heroBg: _DC.heroBg,
  shimmerBase: _DC.shimBase, shimmerHighlight: _DC.shimHigh,
);

// ── AppTheme ─────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get lightTheme {
    final c = lightColors;
    final t = _buildTypography(c);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: c.ink, onPrimary: c.accent,
        secondary: c.accent, surface: c.surfaceWhite,
        onSurface: c.ink, error: c.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0, scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.ink),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: c.ink, letterSpacing: -0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.ink, foregroundColor: c.accent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: c.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: c.inkMuted),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: c.inkSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      extensions: [c, t],
    );
  }

  static ThemeData get darkTheme {
    final c = darkColors;
    final t = _buildTypography(c);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: c.ink, onPrimary: c.accent,
        secondary: c.accent, surface: c.surfaceWhite,
        onSurface: c.ink, error: c.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0, scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.ink),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: c.ink, letterSpacing: -0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent, foregroundColor: c.accentDeep,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: c.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: c.inkMuted),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: c.inkSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      extensions: [c, t],
    );
  }
}
