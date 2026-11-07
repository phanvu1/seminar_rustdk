import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static const String defaultFont = 'Segoe UI';
  static const List<String> fontFallbacks = [
    'Segoe UI',
    'Roboto',
    'Arial',
    'Microsoft Sans Serif',
    'Tahoma',
    'sans-serif',
  ];

  /// Tạo TextTheme chuẩn Unicode tiếng Việt cho Windows Desktop
  static TextTheme _buildTextTheme({required bool isDark}) {
    final baseColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final mutedColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: defaultFont,
    fontFamilyFallback: fontFallbacks,
    brightness: Brightness.light,
    primaryColor: AppConstants.primaryBlue,
    scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: AppConstants.primaryBlue,
      secondary: AppConstants.secondaryBlue,
      surface: Colors.white,
      error: AppConstants.statusRejected,
      onPrimary: Colors.white,
      onSurface: Color(0xFF1E293B),
    ),
    textTheme: _buildTextTheme(isDark: false),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      contentTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        color: Color(0xFF334155),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      dataTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        color: Color(0xFF334155),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: defaultFont,
          fontFamilyFallback: fontFallbacks,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: defaultFont,
          fontFamilyFallback: fontFallbacks,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: defaultFont,
          fontFamilyFallback: fontFallbacks,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        color: Color(0xFF94A3B8),
        fontSize: 13,
      ),
      labelStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        color: Color(0xFF475569),
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppConstants.primaryBlue, width: 1.5),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: defaultFont,
    fontFamilyFallback: fontFallbacks,
    brightness: Brightness.dark,
    primaryColor: AppConstants.primaryBlue,
    scaffoldBackgroundColor: const Color(0xFF0B132B), // Very dark navy
    cardColor: const Color(0xFF1E293B), // Slate 800
    colorScheme: const ColorScheme.dark(
      primary: AppConstants.primaryBlue,
      secondary: AppConstants.secondaryBlue,
      surface: Color(0xFF1E293B),
      error: AppConstants.statusRejected,
      onPrimary: Colors.white,
      onSurface: Color(0xFFF8FAFC),
    ),
    textTheme: _buildTextTheme(isDark: true),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Color(0xFFF8FAFC),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF8FAFC),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF8FAFC),
      ),
      contentTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        color: Color(0xFFCBD5E1),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF8FAFC),
      ),
      dataTextStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        color: Color(0xFFCBD5E1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: defaultFont,
          fontFamilyFallback: fontFallbacks,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: defaultFont,
          fontFamilyFallback: fontFallbacks,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: defaultFont,
          fontFamilyFallback: fontFallbacks,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        color: Color(0xFF64748B),
        fontSize: 13,
      ),
      labelStyle: const TextStyle(
        fontFamily: defaultFont,
        fontFamilyFallback: fontFallbacks,
        color: Color(0xFF94A3B8),
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppConstants.primaryBlue, width: 1.5),
      ),
    ),
  );
}
