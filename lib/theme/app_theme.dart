import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the AI-powered note-taking application.
/// Implements Intelligent Minimalism design with Adaptive Intelligence color palette.
class AppTheme {
  AppTheme._();

  // Adaptive Intelligence Color Palette - optimized for mobile productivity
  static const Color primaryLight =
      Color(0xFF2563EB); // Deep blue for trust and intelligence
  static const Color primaryVariantLight = Color(0xFF1D4ED8);
  static const Color secondaryLight =
      Color(0xFF64748B); // Neutral slate for supporting elements
  static const Color secondaryVariantLight = Color(0xFF475569);
  static const Color accentLight =
      Color(0xFF10B981); // Success green for positive AI insights
  static const Color backgroundLight =
      Color(0xFFFAFAFA); // Warm off-white reducing eye strain
  static const Color surfaceLight =
      Color(0xFFFFFFFF); // Pure white for note cards
  static const Color errorLight =
      Color(0xFFEF4444); // Clear red for validation errors
  static const Color warningLight =
      Color(0xFFF59E0B); // Amber for subscription reminders
  static const Color textPrimaryLight =
      Color(0xFF1F2937); // High contrast for main content
  static const Color textSecondaryLight =
      Color(0xFF6B7280); // Medium gray for metadata
  static const Color borderLight =
      Color(0xFFE5E7EB); // Subtle gray for necessary divisions

  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color primaryVariantDark = Color(0xFF2563EB);
  static const Color secondaryDark = Color(0xFF94A3B8);
  static const Color secondaryVariantDark = Color(0xFF64748B);
  static const Color accentDark = Color(0xFF34D399);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color errorDark = Color(0xFFF87171);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Card and dialog colors for depth hierarchy
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF334155);

  // Shadow colors for subtle elevation (2-4dp blur radius, 20% opacity)
  static const Color shadowLight = Color(0x33000000); // 20% opacity black
  static const Color shadowDark = Color(0x33000000);

  // Divider colors - minimal usage preference
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF334155);

  /// Light theme optimized for productivity and extended mobile use
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryLight,
          onPrimary: Colors.white,
          primaryContainer: primaryVariantLight,
          onPrimaryContainer: Colors.white,
          secondary: secondaryLight,
          onSecondary: Colors.white,
          secondaryContainer: secondaryVariantLight,
          onSecondaryContainer: Colors.white,
          tertiary: accentLight,
          onTertiary: Colors.white,
          tertiaryContainer: accentLight.withValues(alpha: 0.1),
          onTertiaryContainer: accentLight,
          error: errorLight,
          onError: Colors.white,
          surface: surfaceLight,
          onSurface: textPrimaryLight,
          onSurfaceVariant: textSecondaryLight,
          outline: borderLight,
          outlineVariant: borderLight.withValues(alpha: 0.5),
          shadow: shadowLight,
          scrim: Colors.black54,
          inverseSurface: surfaceDark,
          onInverseSurface: textPrimaryDark,
          inversePrimary: primaryDark),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      dividerColor: dividerLight,

      // AppBar theme for clean header design
      appBarTheme: AppBarTheme(
          backgroundColor: backgroundLight,
          foregroundColor: textPrimaryLight,
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: shadowLight,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimaryLight)),

      // Card theme with subtle elevation for note cards
      cardTheme: CardTheme(
          color: cardLight,
          elevation: 2.0,
          shadowColor: shadowLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),

      // Bottom navigation optimized for one-handed operation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: primaryLight,
          unselectedItemColor: textSecondaryLight,
          elevation: 8,
          type: BottomNavigationBarType.fixed),

      // Smart FAB theme for context-aware note capture
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),

      // Button themes following contemporary mobile patterns
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 2,
              shadowColor: shadowLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: borderLight, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),

      // Typography using Inter for optimal mobile readability
      textTheme: _buildTextTheme(isLight: true),

      // Input decoration optimized for note-taking workflows
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceLight,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: borderLight, width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: borderLight, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: primaryLight, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: errorLight, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorLight, width: 2)),
          labelStyle: GoogleFonts.inter(color: textSecondaryLight, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textSecondaryLight.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w400),
          errorStyle: GoogleFonts.inter(color: errorLight, fontSize: 14, fontWeight: FontWeight.w400)),

      // Interactive elements with purposeful accent colors
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.grey.shade400;
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.3);
        }
        return Colors.grey.shade300;
      })),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentLight;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: BorderSide(color: borderLight, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textSecondaryLight;
      })),

      // AI processing indicators with meaningful progress
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryLight, linearTrackColor: primaryLight.withValues(alpha: 0.2), circularTrackColor: primaryLight.withValues(alpha: 0.2)),
      sliderTheme: SliderThemeData(activeTrackColor: primaryLight, thumbColor: primaryLight, overlayColor: primaryLight.withValues(alpha: 0.2), inactiveTrackColor: borderLight, trackHeight: 4),
      tabBarTheme: TabBarTheme(labelColor: primaryLight, unselectedLabelColor: textSecondaryLight, indicatorColor: primaryLight, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: textPrimaryLight.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      snackBarTheme: SnackBarThemeData(backgroundColor: textPrimaryLight, contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: accentLight, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),

      // Bottom sheet theme for contextual actions
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surfaceLight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), elevation: 8, modalBackgroundColor: surfaceLight, modalElevation: 8),

      // Chip theme for filter and category elements
      chipTheme: ChipThemeData(backgroundColor: borderLight.withValues(alpha: 0.3), selectedColor: primaryLight.withValues(alpha: 0.1), labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryLight), secondaryLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primaryLight), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      dialogTheme: DialogThemeData(backgroundColor: dialogLight));

  /// Dark theme optimized for low-light productivity sessions
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryDark,
          onPrimary: Colors.white,
          primaryContainer: primaryVariantDark,
          onPrimaryContainer: Colors.white,
          secondary: secondaryDark,
          onSecondary: backgroundDark,
          secondaryContainer: secondaryVariantDark,
          onSecondaryContainer: Colors.white,
          tertiary: accentDark,
          onTertiary: backgroundDark,
          tertiaryContainer: accentDark.withValues(alpha: 0.2),
          onTertiaryContainer: accentDark,
          error: errorDark,
          onError: backgroundDark,
          surface: surfaceDark,
          onSurface: textPrimaryDark,
          onSurfaceVariant: textSecondaryDark,
          outline: borderDark,
          outlineVariant: borderDark.withValues(alpha: 0.5),
          shadow: shadowDark,
          scrim: Colors.black87,
          inverseSurface: surfaceLight,
          onInverseSurface: textPrimaryLight,
          inversePrimary: primaryLight),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      dividerColor: dividerDark,
      appBarTheme: AppBarTheme(
          backgroundColor: backgroundDark,
          foregroundColor: textPrimaryDark,
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: shadowDark,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimaryDark)),
      cardTheme: CardTheme(
          color: cardDark,
          elevation: 2.0,
          shadowColor: shadowDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryDark,
          unselectedItemColor: textSecondaryDark,
          elevation: 8,
          type: BottomNavigationBarType.fixed),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 2,
              shadowColor: shadowDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: borderDark, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textTheme: _buildTextTheme(isLight: false),
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceDark,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: borderDark, width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: borderDark, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: primaryDark, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: errorDark, width: 1)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: errorDark, width: 2)),
          labelStyle: GoogleFonts.inter(color: textSecondaryDark, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textSecondaryDark.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w400),
          errorStyle: GoogleFonts.inter(color: errorDark, fontSize: 14, fontWeight: FontWeight.w400)),
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.grey.shade600;
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.3);
        }
        return Colors.grey.shade700;
      })),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentDark;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(backgroundDark),
          side: BorderSide(color: borderDark, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textSecondaryDark;
      })),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryDark, linearTrackColor: primaryDark.withValues(alpha: 0.2), circularTrackColor: primaryDark.withValues(alpha: 0.2)),
      sliderTheme: SliderThemeData(activeTrackColor: primaryDark, thumbColor: primaryDark, overlayColor: primaryDark.withValues(alpha: 0.2), inactiveTrackColor: borderDark, trackHeight: 4),
      tabBarTheme: TabBarTheme(labelColor: primaryDark, unselectedLabelColor: textSecondaryDark, indicatorColor: primaryDark, indicatorSize: TabBarIndicatorSize.label, labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600), unselectedLabelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: textPrimaryDark.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: backgroundDark, fontSize: 14, fontWeight: FontWeight.w400), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      snackBarTheme: SnackBarThemeData(backgroundColor: textPrimaryDark, contentTextStyle: GoogleFonts.inter(color: backgroundDark, fontSize: 16, fontWeight: FontWeight.w400), actionTextColor: accentDark, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surfaceDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), elevation: 8, modalBackgroundColor: surfaceDark, modalElevation: 8),
      chipTheme: ChipThemeData(backgroundColor: borderDark.withValues(alpha: 0.3), selectedColor: primaryDark.withValues(alpha: 0.2), labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryDark), secondaryLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primaryDark), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      dialogTheme: DialogThemeData(backgroundColor: dialogDark));

  /// Helper method to build Inter-based text theme optimized for mobile note-taking
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textPrimaryLight : textPrimaryDark;
    final Color textSecondary =
        isLight ? textSecondaryLight : textSecondaryDark;

    return TextTheme(
        // Display styles for large headings
        displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.25),
        displayMedium: GoogleFonts.inter(
            fontSize: 45, fontWeight: FontWeight.w700, color: textPrimary),
        displaySmall: GoogleFonts.inter(
            fontSize: 36, fontWeight: FontWeight.w600, color: textPrimary),

        // Headline styles for section headers
        headlineLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),

        // Title styles for note titles and UI elements
        titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0),
        titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.15),
        titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1),

        // Body styles for note content - optimized for extended reading
        bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: 0.5,
            height: 1.5),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: 0.25,
            height: 1.43),
        bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            letterSpacing: 0.4,
            height: 1.33),

        // Label styles for buttons and metadata
        labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1),
        labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.5));
  }
}
