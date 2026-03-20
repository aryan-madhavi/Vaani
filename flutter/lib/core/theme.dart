import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from the Vaani website (gh-pages/index.html).
class AppColors {
  AppColors._();

  // ── Dark palette ────────────────────────────────────────────────────────────
  static const darkBg       = Color(0xFF080706);
  static const darkSurface  = Color(0xFF1C1714);
  static const darkSurface2 = Color(0xFF251F19);
  static const darkBorder   = Color(0x12FFFFFF); // rgba(255,255,255,.07)

  // ── Accent ──────────────────────────────────────────────────────────────────
  static const amber        = Color(0xFFE8874A);
  static const amberDim     = Color(0x1FE8874A); // 12%
  static const amberGlow    = Color(0x38E8874A); // 22%
  static const mint         = Color(0xFF6EE7B7);
  static const mintDim      = Color(0x1F6EE7B7);

  // ── Dark text ────────────────────────────────────────────────────────────────
  static const textPrimary  = Color(0xFFF0EBE5);
  static const textDim      = Color(0xFF8A8078);
  static const textMuted    = Color(0xFF4A4440);

  // ── Light palette ────────────────────────────────────────────────────────────
  static const lightBg      = Color(0xFFFDF8F3);
  static const lightSurface = Color(0xFFF5EDE3);
  static const lightSurface2= Color(0xFFEDE0D4);
  static const lightBorder  = Color(0x18000000);
  static const amberLight   = Color(0xFFC96C2A);
  static const mintLight    = Color(0xFF2BAF83);
  static const textLight    = Color(0xFF1A1210);
  static const textLightDim = Color(0xFF6B5E58);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const errorRed     = Color(0xFFFF6B6B);
  static const successGreen = mint;
}

/// Theme-aware colour palette. Registered on both [AppTheme.dark] and
/// [AppTheme.light] via `extensions`. Access with `AppColorScheme.of(context)`.
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.textPrimary,
    required this.textDim,
    required this.textMuted,
    required this.amber,
    required this.amberDim,
    required this.amberGlow,
    required this.mint,
    required this.mintDim,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color textPrimary;
  final Color textDim;
  final Color textMuted;
  final Color amber;
  final Color amberDim;
  final Color amberGlow;
  final Color mint;
  final Color mintDim;

  static const _dark = AppColorScheme(
    bg:          AppColors.darkBg,
    surface:     AppColors.darkSurface,
    surface2:    AppColors.darkSurface2,
    border:      AppColors.darkBorder,
    textPrimary: AppColors.textPrimary,
    textDim:     AppColors.textDim,
    textMuted:   AppColors.textMuted,
    amber:       AppColors.amber,
    amberDim:    AppColors.amberDim,
    amberGlow:   AppColors.amberGlow,
    mint:        AppColors.mint,
    mintDim:     AppColors.mintDim,
  );

  static const _light = AppColorScheme(
    bg:          AppColors.lightBg,
    surface:     AppColors.lightSurface,
    surface2:    AppColors.lightSurface2,
    border:      AppColors.lightBorder,
    textPrimary: AppColors.textLight,
    textDim:     AppColors.textLightDim,
    textMuted:   Color(0xFFD8CBBF),
    amber:       AppColors.amberLight,
    amberDim:    Color(0x1FC96C2A),
    amberGlow:   Color(0x38C96C2A),
    mint:        AppColors.mintLight,
    mintDim:     Color(0x1F2BAF83),
  );

  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).extension<AppColorScheme>()!;

  @override
  AppColorScheme copyWith({
    Color? bg, Color? surface, Color? surface2, Color? border,
    Color? textPrimary, Color? textDim, Color? textMuted,
    Color? amber, Color? amberDim, Color? amberGlow,
    Color? mint, Color? mintDim,
  }) => AppColorScheme(
    bg:          bg          ?? this.bg,
    surface:     surface     ?? this.surface,
    surface2:    surface2    ?? this.surface2,
    border:      border      ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary,
    textDim:     textDim     ?? this.textDim,
    textMuted:   textMuted   ?? this.textMuted,
    amber:       amber       ?? this.amber,
    amberDim:    amberDim    ?? this.amberDim,
    amberGlow:   amberGlow   ?? this.amberGlow,
    mint:        mint        ?? this.mint,
    mintDim:     mintDim     ?? this.mintDim,
  );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      bg:          Color.lerp(bg,          other.bg,          t)!,
      surface:     Color.lerp(surface,     other.surface,     t)!,
      surface2:    Color.lerp(surface2,    other.surface2,    t)!,
      border:      Color.lerp(border,      other.border,      t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textDim:     Color.lerp(textDim,     other.textDim,     t)!,
      textMuted:   Color.lerp(textMuted,   other.textMuted,   t)!,
      amber:       Color.lerp(amber,       other.amber,       t)!,
      amberDim:    Color.lerp(amberDim,    other.amberDim,    t)!,
      amberGlow:   Color.lerp(amberGlow,   other.amberGlow,   t)!,
      mint:        Color.lerp(mint,        other.mint,        t)!,
      mintDim:     Color.lerp(mintDim,     other.mintDim,     t)!,
    );
  }
}

TextTheme _buildTextTheme(TextTheme base, Color bodyColor, Color displayColor) {
  return GoogleFonts.dmSansTextTheme(base).copyWith(
    displayLarge:   GoogleFonts.syne(color: displayColor, fontWeight: FontWeight.w800, letterSpacing: -1.0),
    displayMedium:  GoogleFonts.syne(color: displayColor, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    displaySmall:   GoogleFonts.syne(color: displayColor, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    headlineLarge:  GoogleFonts.syne(color: displayColor, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    headlineMedium: GoogleFonts.syne(color: displayColor, fontWeight: FontWeight.w600, letterSpacing: -0.3),
    headlineSmall:  GoogleFonts.syne(color: displayColor, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    titleLarge:     GoogleFonts.syne(color: displayColor, fontWeight: FontWeight.w600),
    titleMedium:    GoogleFonts.dmSans(color: displayColor, fontWeight: FontWeight.w500, fontSize: 16),
    titleSmall:     GoogleFonts.dmSans(color: displayColor, fontWeight: FontWeight.w500, fontSize: 14),
    bodyLarge:      GoogleFonts.dmSans(color: bodyColor, fontWeight: FontWeight.w400, fontSize: 16, height: 1.6),
    bodyMedium:     GoogleFonts.dmSans(color: bodyColor, fontWeight: FontWeight.w400, fontSize: 14, height: 1.5),
    bodySmall:      GoogleFonts.dmSans(color: bodyColor, fontWeight: FontWeight.w400, fontSize: 12, height: 1.4),
    labelLarge:     GoogleFonts.dmSans(color: bodyColor, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
    labelMedium:    GoogleFonts.dmSans(color: bodyColor, fontWeight: FontWeight.w500, fontSize: 12, letterSpacing: 0.3),
    labelSmall:     GoogleFonts.dmSans(color: bodyColor, fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.5),
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary:                AppColors.amber,
      onPrimary:              AppColors.darkBg,
      primaryContainer:       AppColors.amberDim,
      onPrimaryContainer:     AppColors.amber,
      secondary:              AppColors.mint,
      onSecondary:            AppColors.darkBg,
      secondaryContainer:     AppColors.mintDim,
      onSecondaryContainer:   AppColors.mint,
      surface:                AppColors.darkSurface,
      onSurface:              AppColors.textPrimary,
      surfaceContainerHighest: AppColors.darkSurface2,
      onSurfaceVariant:       AppColors.textDim,
      outline:                AppColors.darkBorder,
      outlineVariant:         AppColors.textMuted,
      error:                  AppColors.errorRed,
      onError:                AppColors.darkBg,
      scrim:                  Color(0xCC080706),
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme, AppColors.textPrimary, AppColors.textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textDim, size: 22),
      actionsIconTheme: const IconThemeData(color: AppColors.textDim, size: 22),
      titleTextStyle: GoogleFonts.syne(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 15),
      prefixIconColor: AppColors.textDim,
      suffixIconColor: AppColors.textDim,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.darkBg,
        disabledBackgroundColor: AppColors.amberDim,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.1),
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkSurface2,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.amber,
        side: const BorderSide(color: AppColors.amber),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(0, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.amber,
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textDim,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: AppColors.textDim,
      titleTextStyle: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      subtitleTextStyle: GoogleFonts.dmSans(color: AppColors.textDim, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      minVerticalPadding: 12,
    ),
    iconTheme: const IconThemeData(color: AppColors.textDim, size: 22),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.amber,
      foregroundColor: AppColors.darkBg,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface2,
      contentTextStyle: GoogleFonts.dmSans(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface2,
      labelStyle: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: AppColors.darkBorder),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.amber,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.amber : AppColors.textMuted),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.amberDim : AppColors.darkSurface2),
    ),
    extensions: const [AppColorScheme._dark],
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary:                AppColors.amberLight,
      onPrimary:              Colors.white,
      primaryContainer:       Color(0xFFFFF0E4),
      onPrimaryContainer:     AppColors.amberLight,
      secondary:              AppColors.mintLight,
      onSecondary:            Colors.white,
      secondaryContainer:     Color(0xFFD4F5EB),
      onSecondaryContainer:   AppColors.mintLight,
      surface:                AppColors.lightSurface,
      onSurface:              AppColors.textLight,
      surfaceContainerHighest: AppColors.lightSurface2,
      onSurfaceVariant:       AppColors.textLightDim,
      outline:                AppColors.lightBorder,
      outlineVariant:         Color(0xFFD8CBBF),
      error:                  Color(0xFFD32F2F),
      onError:                Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme: _buildTextTheme(ThemeData.light().textTheme, AppColors.textLight, AppColors.textLight),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBg,
      foregroundColor: AppColors.textLight,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.syne(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.amberLight, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(color: AppColors.textLightDim, fontSize: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amberLight,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.amberLight),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      titleTextStyle: GoogleFonts.dmSans(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w500),
      subtitleTextStyle: GoogleFonts.dmSans(color: AppColors.textLightDim, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      minVerticalPadding: 12,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.amberLight,
    ),
    extensions: const [AppColorScheme._light],
  );
}
