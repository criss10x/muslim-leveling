import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemePreset {
  darkEmerald('darkEmerald', 'Emerald', 'Gelap', false),
  darkNightMosque('darkNightMosque', 'Night Mosque', 'Gelap', false),
  lightEmerald('lightEmerald', 'Emerald', 'Terang', true),
  lightMushaf('lightMushaf', 'Mushaf', 'Terang', true);

  const AppThemePreset(
    this.storageValue,
    this.label,
    this.modeLabel,
    this.isLight,
  );

  final String storageValue;
  final String label;
  final String modeLabel;
  final bool isLight;
}

AppThemePreset _activeThemePreset = AppThemePreset.darkEmerald;
AppThemePreset get activeThemePreset => _activeThemePreset;
set activeThemePreset(AppThemePreset value) {
  _activeThemePreset = value;
  _isLight = value.isLight;
}

/// Global light/dark toggle — read by AppColors getters.
/// MUTATION: hanya lewat ThemeNotifier (theme_service.dart), jangan set langsung.
bool _isLight = false;
bool get isLightTheme => _isLight;
set isLightTheme(bool v) => _isLight = v;

/// ── Dark theme — pure black canvas + Electric Jade pair ──
/// Canvas = #000000 (true black). Cards keep slight green undertone so
/// elevated surfaces still separate without shadow.
class AppColorsDark {
  static const background = Color(0xFF000000);
  static const surfaceDim = Color(0xFF000000);
  static const surface = Color(0xFF000000);
  static const surfaceBright = Color(0xFF2A2F2C);
  static const surfaceContainerLowest = Color(0xFF000000);
  static const surfaceContainerLow = Color(0xFF121816);
  static const surfaceContainer = Color(0xFF161C19);
  static const surfaceContainerHigh = Color(0xFF1E2522);
  static const surfaceContainerHighest = Color(0xFF2A312E);
  static const surfaceVariant = Color(0xFF2A312E);

  static const onSurface = Color(0xFFDCE4DE);
  static const onSurfaceVariant = Color(0xFFBACAC1);
  static const onBackground = Color(0xFFDCE4DE);
  static const outline = Color(0xFF85948C);
  static const outlineVariant = Color(0xFF3C4A43);

  // Bright energy on dark (Strava-loud emerald). onPrimary = deep ink, not white.
  static const primary = Color(0xFF34D399);
  static const primaryFixed = Color(0xFF6EE7B7);
  static const primaryFixedDim = Color(0xFF34D399);
  static const primaryContainer = Color(0xFF047857);
  static const onPrimary = Color(0xFF064E3B);
  static const onPrimaryFixed = Color(0xFF002116);
  static const onPrimaryFixedVariant = Color(0xFF00513B);
  static const onPrimaryContainer = Color(0xFFD1FAE5);
  static const surfaceTint = Color(0xFF34D399);
  static const inversePrimary = Color(0xFF047857);

  static const secondary = Color(0xFFFFF9EF);
  static const secondaryContainer = Color(0xFFFFDB3C);
  static const secondaryFixed = Color(0xFFFFE16D);
  static const secondaryFixedDim = Color(0xFFE9C400);
  static const onSecondary = Color(0xFF3A3000);
  static const onSecondaryContainer = Color(0xFF725F00);
  static const onSecondaryFixed = Color(0xFF221B00);
  static const onSecondaryFixedVariant = Color(0xFF544600);

  static const tertiary = Color(0xFF00E1EF);
  static const tertiaryContainer = Color(0xFF00C3CF);
  static const tertiaryFixed = Color(0xFF7DF4FF);
  static const tertiaryFixedDim = Color(0xFF00DBE9);
  static const onTertiary = Color(0xFF00363A);
  static const onTertiaryContainer = Color(0xFF004B50);
  static const onTertiaryFixed = Color(0xFF002022);
  static const onTertiaryFixedVariant = Color(0xFF004F54);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);
}

/// ── Light theme — Strava-like neutrals + Electric Jade deep action ──
class AppColorsLight {
  // Strava structure: grey canvas, white cards, black ink, one action color.
  // Brand pair: deep #047857 (light primary) + bright #34D399 (dark primary / fill).
  // Card Δ vs canvas ~1.21 (white on cool grey) — separation is lightness + hairline,
  // not shadow. Deepen canvas only if cards still feel glued after ship.
  //
  // NOTE — M3 name inversion (intentional):
  // High/Highest = darker INSETS (tracks/chips). Low/Lowest = white RAISED cards.
  static const background = Color(0xFFE8EAED);              // recessed canvas
  static const surfaceDim = Color(0xFFE8EAED);
  static const surface = Color(0xFFE8EAED);
  static const surfaceBright = Color(0xFFE8EAED);
  static const surfaceContainerLowest = Color(0xFFFFFFFF); // top elevated
  static const surfaceContainerLow = Color(0xFFFFFFFF);    // cards (FlatCard)
  static const surfaceContainer = Color(0xFFFFFFFF);       // panels
  static const surfaceContainerHigh = Color(0xFFE5E7EB);   // chips / tracks (inset)
  static const surfaceContainerHighest = Color(0xFFD1D5DB);// progress empty
  static const surfaceVariant = Color(0xFFE5E7EB);

  static const onSurface = Color(0xFF1A1A1A);       // body
  static const onSurfaceVariant = Color(0xFF5C6370);// labels
  static const onBackground = Color(0xFF1A1A1A);
  static const outline = Color(0xFF8B929E);         // UI chrome ≥3:1 on white
  static const outlineVariant = Color(0xFFC5CAD3);  // hairlines only

  // Deep action emerald — CTA / nav / progress fill. White-on-primary AA.
  // primaryFixed = bright fill/chrome only, NEVER body text on light.
  static const primary = Color(0xFF047857);
  static const primaryFixed = Color(0xFF34D399);
  static const primaryFixedDim = Color(0xFF10B981);
  static const primaryContainer = Color(0xFFD1FAE5);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryFixed = Color(0xFF002116);
  static const onPrimaryFixedVariant = Color(0xFF00513B);
  static const onPrimaryContainer = Color(0xFF064E3B);
  static const surfaceTint = Color(0xFF047857);
  static const inversePrimary = Color(0xFF34D399);

  // Secondary — reward gold (streak / XP)
  // secondaryFixed = gold INK (AA). secondaryFixedDim = gold FILL only.
  static const secondary = Color(0xFF9A6700);
  static const secondaryContainer = Color(0xFFF5D76E);
  static const secondaryFixed = Color(0xFF9A6700);
  static const secondaryFixedDim = Color(0xFFE8B923);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF2A1F00);
  static const onSecondaryFixed = Color(0xFF2A1F00);
  static const onSecondaryFixedVariant = Color(0xFF5C4300);

  // Tertiary — live blue (current prayer / HUD now)
  static const tertiary = Color(0xFF0B6E99);
  static const tertiaryContainer = Color(0xFFD7F0FA);
  static const tertiaryFixed = Color(0xFF7DD3F0);    // fill only
  static const tertiaryFixedDim = Color(0xFF2BA3D4);
  static const onTertiary = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF00344A);
  static const onTertiaryFixed = Color(0xFF002022);
  static const onTertiaryFixedVariant = Color(0xFF004F54);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);
}

/// Dynamic AppColors — delegates to dark or light palette based on [_isLight].
/// All 22+ consumer files continue working without changes.
class AppColorsNightMosque {
  static const background = Color(0xFF071923);
  static const surfaceDim = Color(0xFF071923);
  static const surface = Color(0xFF0B202B);
  static const surfaceBright = Color(0xFF203640);
  static const surfaceContainerLowest = Color(0xFF071923);
  static const surfaceContainerLow = Color(0xFF102934);
  static const surfaceContainer = Color(0xFF16323D);
  static const surfaceContainerHigh = Color(0xFF1F3D48);
  static const surfaceContainerHighest = Color(0xFF294B56);
  static const surfaceVariant = Color(0xFF294B56);
  static const onSurface = Color(0xFFD9E9E9);
  static const onSurfaceVariant = Color(0xFFB7CCCC);
  static const onBackground = Color(0xFFD9E9E9);
  static const outline = Color(0xFF839A9A);
  static const outlineVariant = Color(0xFF3A5158);
  static const primary = Color(0xFF5CD5C4);
  static const primaryFixed = Color(0xFF88E6D7);
  static const primaryFixedDim = Color(0xFF5CD5C4);
  static const primaryContainer = Color(0xFF176B63);
  static const onPrimary = Color(0xFF003D38);
  static const onPrimaryFixed = Color(0xFF00201D);
  static const onPrimaryFixedVariant = Color(0xFF005047);
  static const onPrimaryContainer = Color(0xFFB5F2E6);
  static const surfaceTint = Color(0xFF5CD5C4);
  static const inversePrimary = Color(0xFF176B63);
  static const secondary = Color(0xFFFFE08A);
  static const secondaryContainer = Color(0xFF725B16);
  static const secondaryFixed = Color(0xFFFFE08A);
  static const secondaryFixedDim = Color(0xFFE6C052);
  static const onSecondary = Color(0xFF3B2F00);
  static const onSecondaryContainer = Color(0xFFFFE9B0);
  static const onSecondaryFixed = Color(0xFF241A00);
  static const onSecondaryFixedVariant = Color(0xFF5A4600);
  static const tertiary = Color(0xFF76D5F5);
  static const tertiaryContainer = Color(0xFF24576D);
  static const tertiaryFixed = Color(0xFFB0EAFF);
  static const tertiaryFixedDim = Color(0xFF76D5F5);
  static const onTertiary = Color(0xFF003544);
  static const onTertiaryContainer = Color(0xFFD1F2FF);
  static const onTertiaryFixed = Color(0xFF001F29);
  static const onTertiaryFixedVariant = Color(0xFF004E63);
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);
}

class AppColorsMushaf {
  static const background = Color(0xFFF7F0E2);
  static const surfaceDim = Color(0xFFF1E8D6);
  static const surface = Color(0xFFFFFBF3);
  static const surfaceBright = Color(0xFFFFFBF3);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFFFFBF3);
  static const surfaceContainer = Color(0xFFFFF8EA);
  static const surfaceContainerHigh = Color(0xFFEDE1C9);
  static const surfaceContainerHighest = Color(0xFFE2D3B5);
  static const surfaceVariant = Color(0xFFEDE1C9);
  static const onSurface = Color(0xFF242018);
  static const onSurfaceVariant = Color(0xFF625B4C);
  static const onBackground = Color(0xFF242018);
  static const outline = Color(0xFF8A8170);
  static const outlineVariant = Color(0xFFD1C5AE);
  static const primary = Color(0xFF276749);
  static const primaryFixed = Color(0xFF5FBF82);
  static const primaryFixedDim = Color(0xFF3B9D62);
  static const primaryContainer = Color(0xFFC8EBCF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryFixed = Color(0xFF002112);
  static const onPrimaryFixedVariant = Color(0xFF0B4F2C);
  static const onPrimaryContainer = Color(0xFF07391E);
  static const surfaceTint = Color(0xFF276749);
  static const inversePrimary = Color(0xFF5FBF82);
  static const secondary = Color(0xFF846000);
  static const secondaryContainer = Color(0xFFF2D783);
  static const secondaryFixed = Color(0xFF846000);
  static const secondaryFixedDim = Color(0xFFD8B54F);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF2A2000);
  static const onSecondaryFixed = Color(0xFF2A2000);
  static const onSecondaryFixedVariant = Color(0xFF554000);
  static const tertiary = Color(0xFF176B74);
  static const tertiaryContainer = Color(0xFFC4EAED);
  static const tertiaryFixed = Color(0xFF8BD9DF);
  static const tertiaryFixedDim = Color(0xFF4AAFB8);
  static const onTertiary = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF003B41);
  static const onTertiaryFixed = Color(0xFF002023);
  static const onTertiaryFixedVariant = Color(0xFF004F56);
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);
}

class AppColors {
  static Color _select(Color dark, Color night, Color light, Color mushaf) =>
      switch (activeThemePreset) {
        AppThemePreset.darkEmerald => dark,
        AppThemePreset.darkNightMosque => night,
        AppThemePreset.lightEmerald => light,
        AppThemePreset.lightMushaf => mushaf,
      };

  static Color get background => _select(AppColorsDark.background, AppColorsNightMosque.background, AppColorsLight.background, AppColorsMushaf.background);
  static Color get surfaceDim => _select(AppColorsDark.surfaceDim, AppColorsNightMosque.surfaceDim, AppColorsLight.surfaceDim, AppColorsMushaf.surfaceDim);
  static Color get surface => _select(AppColorsDark.surface, AppColorsNightMosque.surface, AppColorsLight.surface, AppColorsMushaf.surface);
  static Color get surfaceBright => _select(AppColorsDark.surfaceBright, AppColorsNightMosque.surfaceBright, AppColorsLight.surfaceBright, AppColorsMushaf.surfaceBright);
  static Color get surfaceContainerLowest => _select(AppColorsDark.surfaceContainerLowest, AppColorsNightMosque.surfaceContainerLowest, AppColorsLight.surfaceContainerLowest, AppColorsMushaf.surfaceContainerLowest);
  static Color get surfaceContainerLow => _select(AppColorsDark.surfaceContainerLow, AppColorsNightMosque.surfaceContainerLow, AppColorsLight.surfaceContainerLow, AppColorsMushaf.surfaceContainerLow);
  static Color get surfaceContainer => _select(AppColorsDark.surfaceContainer, AppColorsNightMosque.surfaceContainer, AppColorsLight.surfaceContainer, AppColorsMushaf.surfaceContainer);
  static Color get surfaceContainerHigh => _select(AppColorsDark.surfaceContainerHigh, AppColorsNightMosque.surfaceContainerHigh, AppColorsLight.surfaceContainerHigh, AppColorsMushaf.surfaceContainerHigh);
  static Color get surfaceContainerHighest => _select(AppColorsDark.surfaceContainerHighest, AppColorsNightMosque.surfaceContainerHighest, AppColorsLight.surfaceContainerHighest, AppColorsMushaf.surfaceContainerHighest);
  static Color get surfaceVariant => _select(AppColorsDark.surfaceVariant, AppColorsNightMosque.surfaceVariant, AppColorsLight.surfaceVariant, AppColorsMushaf.surfaceVariant);
  static Color get onSurface => _select(AppColorsDark.onSurface, AppColorsNightMosque.onSurface, AppColorsLight.onSurface, AppColorsMushaf.onSurface);
  static Color get onSurfaceVariant => _select(AppColorsDark.onSurfaceVariant, AppColorsNightMosque.onSurfaceVariant, AppColorsLight.onSurfaceVariant, AppColorsMushaf.onSurfaceVariant);
  static Color get onBackground => _select(AppColorsDark.onBackground, AppColorsNightMosque.onBackground, AppColorsLight.onBackground, AppColorsMushaf.onBackground);
  static Color get outline => _select(AppColorsDark.outline, AppColorsNightMosque.outline, AppColorsLight.outline, AppColorsMushaf.outline);
  static Color get outlineVariant => _select(AppColorsDark.outlineVariant, AppColorsNightMosque.outlineVariant, AppColorsLight.outlineVariant, AppColorsMushaf.outlineVariant);
  static Color get primary => _select(AppColorsDark.primary, AppColorsNightMosque.primary, AppColorsLight.primary, AppColorsMushaf.primary);
  static Color get primaryFixed => _select(AppColorsDark.primaryFixed, AppColorsNightMosque.primaryFixed, AppColorsLight.primaryFixed, AppColorsMushaf.primaryFixed);
  static Color get primaryFixedDim => _select(AppColorsDark.primaryFixedDim, AppColorsNightMosque.primaryFixedDim, AppColorsLight.primaryFixedDim, AppColorsMushaf.primaryFixedDim);
  static Color get primaryContainer => _select(AppColorsDark.primaryContainer, AppColorsNightMosque.primaryContainer, AppColorsLight.primaryContainer, AppColorsMushaf.primaryContainer);
  static Color get onPrimary => _select(AppColorsDark.onPrimary, AppColorsNightMosque.onPrimary, AppColorsLight.onPrimary, AppColorsMushaf.onPrimary);
  static Color get onPrimaryFixed => _select(AppColorsDark.onPrimaryFixed, AppColorsNightMosque.onPrimaryFixed, AppColorsLight.onPrimaryFixed, AppColorsMushaf.onPrimaryFixed);
  static Color get onPrimaryFixedVariant => _select(AppColorsDark.onPrimaryFixedVariant, AppColorsNightMosque.onPrimaryFixedVariant, AppColorsLight.onPrimaryFixedVariant, AppColorsMushaf.onPrimaryFixedVariant);
  static Color get onPrimaryContainer => _select(AppColorsDark.onPrimaryContainer, AppColorsNightMosque.onPrimaryContainer, AppColorsLight.onPrimaryContainer, AppColorsMushaf.onPrimaryContainer);
  static Color get surfaceTint => _select(AppColorsDark.surfaceTint, AppColorsNightMosque.surfaceTint, AppColorsLight.surfaceTint, AppColorsMushaf.surfaceTint);
  static Color get inversePrimary => _select(AppColorsDark.inversePrimary, AppColorsNightMosque.inversePrimary, AppColorsLight.inversePrimary, AppColorsMushaf.inversePrimary);
  static Color get secondary => _select(AppColorsDark.secondary, AppColorsNightMosque.secondary, AppColorsLight.secondary, AppColorsMushaf.secondary);
  static Color get secondaryContainer => _select(AppColorsDark.secondaryContainer, AppColorsNightMosque.secondaryContainer, AppColorsLight.secondaryContainer, AppColorsMushaf.secondaryContainer);
  static Color get secondaryFixed => _select(AppColorsDark.secondaryFixed, AppColorsNightMosque.secondaryFixed, AppColorsLight.secondaryFixed, AppColorsMushaf.secondaryFixed);
  static Color get secondaryFixedDim => _select(AppColorsDark.secondaryFixedDim, AppColorsNightMosque.secondaryFixedDim, AppColorsLight.secondaryFixedDim, AppColorsMushaf.secondaryFixedDim);
  static Color get onSecondary => _select(AppColorsDark.onSecondary, AppColorsNightMosque.onSecondary, AppColorsLight.onSecondary, AppColorsMushaf.onSecondary);
  static Color get onSecondaryContainer => _select(AppColorsDark.onSecondaryContainer, AppColorsNightMosque.onSecondaryContainer, AppColorsLight.onSecondaryContainer, AppColorsMushaf.onSecondaryContainer);
  static Color get onSecondaryFixed => _select(AppColorsDark.onSecondaryFixed, AppColorsNightMosque.onSecondaryFixed, AppColorsLight.onSecondaryFixed, AppColorsMushaf.onSecondaryFixed);
  static Color get onSecondaryFixedVariant => _select(AppColorsDark.onSecondaryFixedVariant, AppColorsNightMosque.onSecondaryFixedVariant, AppColorsLight.onSecondaryFixedVariant, AppColorsMushaf.onSecondaryFixedVariant);
  static Color get tertiary => _select(AppColorsDark.tertiary, AppColorsNightMosque.tertiary, AppColorsLight.tertiary, AppColorsMushaf.tertiary);
  static Color get tertiaryContainer => _select(AppColorsDark.tertiaryContainer, AppColorsNightMosque.tertiaryContainer, AppColorsLight.tertiaryContainer, AppColorsMushaf.tertiaryContainer);
  static Color get tertiaryFixed => _select(AppColorsDark.tertiaryFixed, AppColorsNightMosque.tertiaryFixed, AppColorsLight.tertiaryFixed, AppColorsMushaf.tertiaryFixed);
  static Color get tertiaryFixedDim => _select(AppColorsDark.tertiaryFixedDim, AppColorsNightMosque.tertiaryFixedDim, AppColorsLight.tertiaryFixedDim, AppColorsMushaf.tertiaryFixedDim);
  static Color get onTertiary => _select(AppColorsDark.onTertiary, AppColorsNightMosque.onTertiary, AppColorsLight.onTertiary, AppColorsMushaf.onTertiary);
  static Color get onTertiaryContainer => _select(AppColorsDark.onTertiaryContainer, AppColorsNightMosque.onTertiaryContainer, AppColorsLight.onTertiaryContainer, AppColorsMushaf.onTertiaryContainer);
  static Color get onTertiaryFixed => _select(AppColorsDark.onTertiaryFixed, AppColorsNightMosque.onTertiaryFixed, AppColorsLight.onTertiaryFixed, AppColorsMushaf.onTertiaryFixed);
  static Color get onTertiaryFixedVariant => _select(AppColorsDark.onTertiaryFixedVariant, AppColorsNightMosque.onTertiaryFixedVariant, AppColorsLight.onTertiaryFixedVariant, AppColorsMushaf.onTertiaryFixedVariant);
  static Color get error => _select(AppColorsDark.error, AppColorsNightMosque.error, AppColorsLight.error, AppColorsMushaf.error);
  static Color get onError => _select(AppColorsDark.onError, AppColorsNightMosque.onError, AppColorsLight.onError, AppColorsMushaf.onError);
  static Color get errorContainer => _select(AppColorsDark.errorContainer, AppColorsNightMosque.errorContainer, AppColorsLight.errorContainer, AppColorsMushaf.errorContainer);
  static Color get onErrorContainer => _select(AppColorsDark.onErrorContainer, AppColorsNightMosque.onErrorContainer, AppColorsLight.onErrorContainer, AppColorsMushaf.onErrorContainer);

  /// Gold as icon/label ink (AA). Alias of [secondaryFixed] — honest role name.
  static Color get goldInk => secondaryFixed;
  /// Bright gold fill/chrome only. Alias of [secondaryFixedDim].
  static Color get goldFill => secondaryFixedDim;
  /// Cyan as icon/label ink (AA). Alias of [tertiary].
  static Color get cyanInk => tertiary;
}

// radius, spacing, text — unchanged
class AppRadius {
  static const xs = 2.0; static const sm = 4.0; static const md = 6.0;
  static const lg = 8.0; static const xl = 12.0; static const xxl = 16.0;
  static const pill = 999.0;
}
class AppSpacing {
  static const base = 4.0; static const xs = 8.0; static const sm = 12.0;
  static const md = 16.0; static const lg = 24.0; static const xl = 32.0;
  static const xxl = 40.0;
}

/// Card elevation shadows — always empty.
/// Depth comes from the surface lightness ramp (canvas recessed → card raised).
/// Shadow double-counts elevation and violates FlatCard's no-shadow contract.
/// Keep the API so call sites compile; do not reintroduce soft shadows here.
class AppShadow {
  static List<BoxShadow> card({double y = 2, double blur = 10, double opacity = 0.07}) {
    return const [];
  }
}

class AppText {
  static TextStyle displayHero(double size) => GoogleFonts.sora(
        fontSize: size, fontWeight: FontWeight.w800,
        height: size == 40 ? 48 / 40 : 38 / 32,
        letterSpacing: size == 40 ? -0.5 : 0,
      );
  static TextStyle headlineLg() => GoogleFonts.sora(
        fontSize: 32, fontWeight: FontWeight.w700, height: 40 / 32,
      );
  static TextStyle headlineMd() => GoogleFonts.sora(
        fontSize: 24, fontWeight: FontWeight.w700, height: 32 / 24,
      );
  static TextStyle titleLg() => GoogleFonts.plusJakartaSans(
        fontSize: 20, fontWeight: FontWeight.w600, height: 28 / 20,
      );
  static TextStyle bodyLg() => GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16,
      );
  static TextStyle bodyMd() => GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14,
      );
  static TextStyle labelCaps() => GoogleFonts.jetBrainsMono(
        fontSize: 12, fontWeight: FontWeight.w700, height: 16 / 12, letterSpacing: 1.2,
      );
  /// Small caps label (nav, HUD cells). Prefer this over magic fontSize: 9/11.
  static TextStyle labelCapsSm() => GoogleFonts.jetBrainsMono(
        fontSize: 10, fontWeight: FontWeight.w700, height: 14 / 10, letterSpacing: 1.0,
      );
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.withValues(alpha: 0.85),
        elevation: 0,
        titleTextStyle: AppText.titleLg().copyWith(color: AppColors.onSurface),
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
      iconTheme: IconThemeData(color: AppColors.onSurface),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleTextStyle: AppText.titleLg().copyWith(color: AppColors.onSurface),
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
      iconTheme: IconThemeData(color: AppColors.onSurface),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
      ),
    );
  }

  static TextTheme _textTheme() => TextTheme(
    displayLarge: AppText.displayHero(40),
    displayMedium: AppText.displayHero(32),
    headlineLarge: AppText.headlineLg(),
    headlineMedium: AppText.headlineMd(),
    titleLarge: AppText.titleLg(),
    bodyLarge: AppText.bodyLg(),
    bodyMedium: AppText.bodyMd(),
    labelLarge: AppText.labelCaps(),
    labelMedium: AppText.labelCaps(),
    labelSmall: AppText.labelCaps(),
  );
}
