import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette sampled directly from the Packurbag logo
/// (assets/packurbag-logo.png): deep teal, amber, and coral.
const _tealSeed = Color(0xFF075E72);
const _amberSeed = Color(0xFFF9A624);
const _coralSeed = Color(0xFFEF533A);

class AppTheme {
  AppTheme._();

  /// Public brand colors, for widgets that need the exact mark colors rather
  /// than the tonal roles Material derives from them (e.g. the FAB and the
  /// per-trip calendar/tab accents).
  static const teal = _tealSeed;
  static const tealDark = Color(0xFF043A47);
  static const amber = _amberSeed;
  static const coral = _coralSeed;

  /// Corner radii matching the design reference's flat card language
  /// (Tailwind's rounded-2xl / rounded-xl), used directly by widgets instead
  /// of the Material [CardThemeData] so surfaces read as flat tinted blocks
  /// rather than elevated Material cards.
  static const radiusLg = 16.0;
  static const radiusMd = 12.0;

  /// A faint tinted surface for grouped content (trip cards, stat tiles,
  /// calendar, quick actions) — the design reference's `bg-black/[0.03]` in
  /// light mode, `bg-white/[0.06]` in dark mode.
  static Color surfaceMuted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.03);
  }

  /// A slightly stronger tint for interactive surfaces (inputs, pills) — the
  /// design reference's `bg-black/[0.04]`/`bg-black/[0.05]`.
  static Color surfaceInput(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
  }

  /// Hairline dividers/borders — the design reference's `border-black/5`.
  static Color borderMuted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
  }

  /// Primary heading color — flat brand teal-dark rather than a Material
  /// tonal surface color, matching every mock's `text-teal-dark`.
  static Color textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : tealDark;
  }

  /// Muted secondary/caption text — the design reference's `text-black/40`
  /// (light) / `text-white/40` (dark) — ProfileMock.tsx uses the *same*
  /// opacity value in both themes, so [opacity] applies unscaled to either.
  static Color textMuted(BuildContext context, {double opacity = 0.5}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity);
  }

  /// Dark mode swaps the teal accent for amber — teal reads poorly against
  /// the dark navy background (`#0F2328` sits close in luminosity to
  /// teal-dark). Mirrors ProfileMock.tsx's `accent = isDark ? "text-amber"
  /// : "text-teal"`, used here for every interactive brand accent across
  /// the app (icons on tinted circles, selected states, links).
  static Color accent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? amber : teal;
  }

  /// Same swap for elements whose light-mode color is teal-dark rather than
  /// teal — solid CTA/FAB backgrounds and the nav bar's active state.
  /// Mirrors PhoneNavBar.tsx's dark `activeColor = "text-amber"`.
  static Color accentStrong(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? amber : tealDark;
  }

  /// The foreground color to pair with [accentStrong] — white text/icons
  /// read fine on a teal-dark background (light mode), but need to flip to
  /// a dark ink once that background becomes amber (dark mode).
  static Color onAccentStrong(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? tealDark : Colors.white;
  }

  /// A flat, borderless tinted container decoration — the reusable
  /// `rounded-2xl bg-black/[0.03]` card look used throughout every mock.
  static BoxDecoration flatCard(BuildContext context, {double radius = radiusLg, Color? color}) {
    return BoxDecoration(
      color: color ?? surfaceMuted(context),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static ThemeData light() => _themeFrom(Brightness.light);
  static ThemeData dark() => _themeFrom(Brightness.dark);

  static ThemeData _themeFrom(Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: _tealSeed, brightness: brightness);
    final amber = ColorScheme.fromSeed(seedColor: _amberSeed, brightness: brightness);
    final coral = ColorScheme.fromSeed(seedColor: _coralSeed, brightness: brightness);

    // Teal drives primary + surfaces; amber/coral (also from the logo) supply
    // the secondary/tertiary roles instead of Material's auto-derived tones,
    // so the app's palette actually matches the brand mark.
    final colorScheme = base.copyWith(
      secondary: amber.primary,
      onSecondary: amber.onPrimary,
      secondaryContainer: amber.primaryContainer,
      onSecondaryContainer: amber.onPrimaryContainer,
      tertiary: coral.primary,
      onTertiary: coral.onPrimary,
      tertiaryContainer: coral.primaryContainer,
      onTertiaryContainer: coral.onPrimaryContainer,
    );
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      brightness == Brightness.dark
          ? ThemeData(brightness: Brightness.dark).textTheme
          : ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // The design reference uses a flat literal white/near-black background
      // on every screen, not Material's seed-tinted `colorScheme.surface`.
      scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xFF0F2328) : Colors.white,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark ? const Color(0xFF0F2328) : Colors.white,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// Semantic type scale matching the design reference's typographic
/// hierarchy (Plus Jakarta Sans throughout), sized up from the reference's
/// phone-mock proportions to real device density. Screens ported from the
/// design reference use these directly instead of Material's default
/// [TextTheme] slots, whose sizes run larger and don't match the reference.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _f(double size, FontWeight weight, {Color? color, double? height}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color, height: height);

  /// Splash brand name, "Welcome back", "Create your account".
  static TextStyle display({Color? color}) => _f(22, FontWeight.w800, color: color);

  /// Custom thin app-bar titles, trip/card titles.
  static TextStyle appBarTitle({Color? color}) => _f(18, FontWeight.w800, color: color);

  /// Section headers ("Trip calendar", "Quick actions").
  static TextStyle sectionTitle({Color? color}) => _f(15, FontWeight.w800, color: color);

  /// Default readable body text (list rows, input text).
  static TextStyle body({Color? color, FontWeight weight = FontWeight.w500}) => _f(15, weight, color: color);

  /// Buttons and other bold body-sized text.
  static TextStyle bodyBold({Color? color}) => _f(15, FontWeight.w700, color: color);

  /// Secondary labels — destination lines, dates, field labels.
  static TextStyle label({Color? color, FontWeight weight = FontWeight.w600}) => _f(13, weight, color: color);

  /// Muted captions and helper text.
  static TextStyle caption({Color? color}) => _f(12, FontWeight.w500, color: color);

  /// Small pill/badge text (status chips, tags).
  static TextStyle tag({Color? color}) => _f(11, FontWeight.w700, color: color, height: 1.2);

  /// Tiniest labels — nav bar labels, calendar day numbers, stat sub-labels.
  static TextStyle micro({Color? color, FontWeight weight = FontWeight.w600}) => _f(10, weight, color: color);
}
