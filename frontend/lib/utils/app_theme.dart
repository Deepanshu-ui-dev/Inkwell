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
  }) =>
      AppColorsExtension(
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
  }) =>
      AppTypographyExtension(
        hero: hero ?? this.hero,
        heroSub: heroSub ?? this.heroSub,
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
  AppTypographyExtension lerp(covariant AppTypographyExtension? other, double t) {
    if (other == null) return this;
    return AppTypographyExtension(
      hero: TextStyle.lerp(hero, other.hero, t)!,
      heroSub: TextStyle.lerp(heroSub, other.heroSub, t)!,
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

// ── Context Extensions ───────────────────────────────────────────────────────
extension AppThemeExtension on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
  AppTypographyExtension get typography =>
      Theme.of(this).extension<AppTypographyExtension>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  LIGHT PALETTE
//  Warm cream base. Ink-black text. Lime-green accent.
//  Every layer is exactly one step lighter than the one beneath it.
// ─────────────────────────────────────────────────────────────────────────────
class _L {
  // Backgrounds  (warm cream scale — 4 distinct steps)
  static const bg          = Color(0xFFF5F1E8); // page canvas
  static const surface     = Color(0xFFEDE9DF); // input fields, chips, muted areas
  static const card        = Color(0xFFFBF9F5); // cards elevated above bg
  static const white       = Color(0xFFFFFFFF); // pure white: dialogs, sheets

  // Borders & dividers
  static const border      = Color(0xFFDDD8CC); // card outlines, input borders
  static const divider     = Color(0xFFE6E2D8); // horizontal rules

  // Accent — electric lime
  static const accent      = Color(0xFFBEF264); // primary CTA, badges, progress
  static const accentDeep  = Color(0xFF2D5000); // text/icon ON accent bg
  static const accentWarm  = Color(0xFFFF7849); // warm secondary accent

  // Text scale  (4 steps from ink-black to muted)
  static const ink         = Color(0xFF110F0C); // headings, primary text
  static const ink2        = Color(0xFF5A5650); // body, secondary text
  static const ink3        = Color(0xFF9B9589); // captions, placeholders

  // Text on dark surfaces (hero, FAB)
  static const inkDark     = Color(0xFFF5F1E8); // matches bg for warmth

  // Semantic
  static const error       = Color(0xFFCC3B2E);
  static const success     = Color(0xFF237A44);

  // Tag pills
  static const tagBg       = Color(0xFFE5F9A0); // pale lime
  static const tagText     = Color(0xFF2D5000); // same as accentDeep

  // Hero section background
  static const heroBg      = Color(0xFF110F0C); // same as ink for cohesion

  // Skeleton shimmer
  static const shimBase    = Color(0xFFE6E2D8);
  static const shimHigh    = Color(0xFFF2EFE8);
}

// ─────────────────────────────────────────────────────────────────────────────
//  DARK PALETTE
//  True zinc-black base. Bright lime accent for contrast.
//  surfaceWhite in dark mode = the highest-contrast surface, not literal white.
// ─────────────────────────────────────────────────────────────────────────────
class _D {
  // Backgrounds  (cool zinc-black scale — 4 distinct steps)
  static const bg          = Color(0xFF0A0A0C); // true-black page canvas
  static const surface     = Color(0xFF131316); // inputs, chips — 1 step up
  static const card        = Color(0xFF1C1C21); // cards — 2 steps up
  static const white       = Color(0xFF252529); // "white" in dark = highest card

  // Borders & dividers — barely-visible separators
  static const border      = Color(0xFF2E2E35);
  static const divider     = Color(0xFF222228);

  // Accent — brighter lime for dark-mode legibility (higher saturation)
  static const accent      = Color(0xFFA3E635); // lime-400 equivalent
  static const accentDeep  = Color(0xFF1A3300); // dark green for text ON accent
  static const accentWarm  = Color(0xFFFF8A50); // warm secondary (slightly cooler on dark)

  // Text scale  (cool-white to muted zinc)
  static const ink         = Color(0xFFF2F2F5); // near-white primary text
  static const ink2        = Color(0xFFA8A8B3); // secondary / body
  static const ink3        = Color(0xFF6A6A78); // captions, placeholders

  // Text on dark hero/FAB surfaces (the hero IS dark here, same bg)
  static const inkDark     = Color(0xFFF2F2F5); // same as ink — both are already dark-bg

  // Semantic
  static const error       = Color(0xFFFF6B6B); // brighter red for dark contrast
  static const success     = Color(0xFF34D46A); // bright green

  // Tag pills
  static const tagBg       = Color(0xFF1E3300); // deep olive
  static const tagText     = Color(0xFFA3E635); // same as accent

  // Hero section (stays dark-on-dark — use a slightly lighter shade)
  static const heroBg      = Color(0xFF131316); // same as surface for subtle depth

  // Skeleton shimmer
  static const shimBase    = Color(0xFF1C1C21);
  static const shimHigh    = Color(0xFF2A2A31);
}

// ── Color palette instances ──────────────────────────────────────────────────
AppColorsExtension get lightColors => const AppColorsExtension(
  background:      _L.bg,
  surface:         _L.surface,
  surfaceCard:     _L.card,
  surfaceWhite:    _L.white,
  border:          _L.border,
  divider:         _L.divider,
  accent:          _L.accent,
  accentDeep:      _L.accentDeep,
  accentWarm:      _L.accentWarm,
  ink:             _L.ink,
  inkSecondary:    _L.ink2,
  inkMuted:        _L.ink3,
  inkOnDark:       _L.inkDark,
  error:           _L.error,
  success:         _L.success,
  tagBg:           _L.tagBg,
  tagText:         _L.tagText,
  heroBg:          _L.heroBg,
  shimmerBase:     _L.shimBase,
  shimmerHighlight: _L.shimHigh,
);

AppColorsExtension get darkColors => const AppColorsExtension(
  background:      _D.bg,
  surface:         _D.surface,
  surfaceCard:     _D.card,
  surfaceWhite:    _D.white,
  border:          _D.border,
  divider:         _D.divider,
  accent:          _D.accent,
  accentDeep:      _D.accentDeep,
  accentWarm:      _D.accentWarm,
  ink:             _D.ink,
  inkSecondary:    _D.ink2,
  inkMuted:        _D.ink3,
  inkOnDark:       _D.inkDark,
  error:           _D.error,
  success:         _D.success,
  tagBg:           _D.tagBg,
  tagText:         _D.tagText,
  heroBg:          _D.heroBg,
  shimmerBase:     _D.shimBase,
  shimmerHighlight: _D.shimHigh,
);

// ── Typography builder (shared between light/dark) ───────────────────────────
// ink color injected from the palette so text automatically adapts.
AppTypographyExtension _buildTypography(AppColorsExtension c) =>
    AppTypographyExtension(
      // Hero headline: large serif, lives on the dark hero banner
      hero: GoogleFonts.instrumentSerif(
        fontSize: 52,
        fontWeight: FontWeight.w400,
        color: c.inkOnDark,
        height: 0.96,
        letterSpacing: -1.5,
      ),
      // Hero sub-copy
      heroSub: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: c.inkOnDark.withValues(alpha: 0.6),
        height: 1.55,
      ),
      // Large page headings (blog title in detail, screen headers)
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: c.ink,
        height: 1.1,
        letterSpacing: -1.2,
      ),
      // Card/section headings
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: c.ink,
        height: 1.15,
        letterSpacing: -0.6,
      ),
      // Smaller headings (profile name, dialog titles)
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: c.ink,
        height: 1.2,
        letterSpacing: -0.4,
      ),
      // AppBar, section labels, card titles
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: c.ink,
        height: 1.3,
        letterSpacing: -0.3,
      ),
      // Sub-labels, tile labels
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: c.ink,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      // Long-form article reading
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: c.ink,
        height: 1.78,
      ),
      // Supporting text, descriptions
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.inkSecondary,
        height: 1.6,
      ),
      // Meta text, timestamps, counts
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: c.inkMuted,
        height: 1.4,
      ),
      // Buttons, action text, bylines
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.ink,
        letterSpacing: 0.1,
      ),
      // SCREAMING CAPS section labels, badges
      caption: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: c.inkMuted,
        letterSpacing: 1.2,
      ),
    );

// ── AppTheme ─────────────────────────────────────────────────────────────────
class AppTheme {
  // ── Light ──────────────────────────────────────────────────
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
        primary:   c.ink,
        onPrimary: c.accent,
        secondary: c.accent,
        onSecondary: c.accentDeep,
        surface:   c.surfaceCard,
        onSurface: c.ink,
        error:     c.error,
        onError:   c.surfaceWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.ink),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: c.ink,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.ink,
          foregroundColor: c.accent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.ink,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: c.inkMuted),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: c.inkSecondary),
        floatingLabelStyle: GoogleFonts.inter(fontSize: 12, color: c.ink),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.ink, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.error, width: 2.0),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.accent,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        side: BorderSide(color: c.border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceWhite,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      extensions: [c, t],
    );
  }

  // ── Dark ───────────────────────────────────────────────────
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
        primary:   c.accent,
        onPrimary: c.accentDeep,
        secondary: c.accentWarm,
        onSecondary: c.surfaceWhite,
        surface:   c.surfaceCard,
        onSurface: c.ink,
        error:     c.error,
        onError:   c.surfaceWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.ink),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: c.ink,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // In dark mode: accent bg with dark text is far more visible
          backgroundColor: c.accent,
          foregroundColor: c.accentDeep,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // surfaceWhite in dark = the highest card layer, NOT white
        fillColor: c.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: c.inkMuted),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: c.inkSecondary),
        floatingLabelStyle: GoogleFonts.inter(fontSize: 12, color: c.accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          // accent outline on focus for dark mode — more visible than ink
          borderSide: BorderSide(color: c.accent, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.error, width: 2.0),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.accent,
        labelStyle: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600, color: c.ink),
        side: BorderSide(color: c.border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceCard,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      extensions: [c, t],
    );
  }
}