import 'package:flutter/material.dart';

class AppTheme {
  // Spotify-inspired colors
  static const Color spotifyGreen = Color(0xFF1DB954);
  static const Color spotifyBlack = Color(0xFF121212);
  static const Color spotifyDarkGray = Color(0xFF282828);
  static const Color spotifyLightGray = Color(0xFFB3B3B3);
  static const Color spotifyWhite = Color(0xFFFFFFFF);

  // Font family - Noto Sans SC (思源黑体)
  static const String fontFamily = 'NotoSansSC';

  // Text theme using Noto Sans SC (思源黑体)
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    displayMedium: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    displaySmall: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    headlineLarge: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    headlineMedium: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    headlineSmall: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    titleLarge: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    titleMedium: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    titleSmall: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    bodyLarge: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    bodyMedium: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    bodySmall: TextStyle(fontFamily: fontFamily, color: spotifyLightGray),
    labelLarge: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    labelMedium: TextStyle(fontFamily: fontFamily, color: spotifyWhite),
    labelSmall: TextStyle(fontFamily: fontFamily, color: spotifyLightGray),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spotifyBlack,
      primaryColor: spotifyGreen,
      textTheme: _textTheme,
      colorScheme: const ColorScheme.dark(
        primary: spotifyGreen,
        secondary: spotifyGreen,
        surface: spotifyDarkGray,
        onPrimary: spotifyBlack,
        onSecondary: spotifyBlack,
        onSurface: spotifyWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: spotifyBlack,
        foregroundColor: spotifyWhite,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: spotifyWhite,
        ),
      ),
      cardTheme: CardThemeData(
        color: spotifyDarkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: spotifyGreen,
          foregroundColor: spotifyBlack,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: spotifyWhite,
          side: const BorderSide(color: spotifyLightGray),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: spotifyWhite),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: spotifyDarkGray,
        hintStyle: const TextStyle(color: spotifyLightGray),
        labelStyle: const TextStyle(color: spotifyLightGray),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: spotifyGreen),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: spotifyGreen,
        selectionColor: Color(0x401DB954),
        selectionHandleColor: spotifyGreen,
      ),
      iconTheme: const IconThemeData(color: spotifyWhite),
      sliderTheme: const SliderThemeData(
        activeTrackColor: spotifyGreen,
        inactiveTrackColor: spotifyLightGray,
        thumbColor: spotifyWhite,
        overlayColor: Color(0x291DB954),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: spotifyWhite,
        textColor: spotifyWhite,
      ),
      dividerTheme: const DividerThemeData(
        color: spotifyDarkGray,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: spotifyGreen,
      colorScheme: const ColorScheme.light(
        primary: spotifyGreen,
        secondary: spotifyGreen,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
    );
  }
}
