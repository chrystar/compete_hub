import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color lightPrimary = Color(0xFF1976D2); // Blue
  static const Color lightPrimaryVariant = Color(0xFF1565C0); // Darker Blue
  static const Color lightSecondary = Color(0xFF43A047); // Green
  static const Color lightSecondaryVariant = Color(0xFF388E3C); // Darker Green
  
  // Background and surface colors
  static const Color lightBackground = Color(0xFFF5F5F5); // Light grey
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFE0E0E0); // Slightly darker grey
  
  // Text colors
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.white;
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black;
  static const Color lightOnSurfaceVariant = Color(0xFF757575);
  
  // Semantic colors
  static const Color lightError = Color(0xFFD32F2F); // Red
  static const Color lightOnError = Colors.white;
  static const Color lightSuccess = Color(0xFF388E3C); // Green
  static const Color lightWarning = Color(0xFFFFA000); // Amber
  
  // Utility colors
  static const Color lightDivider = Color(0xFFBDBDBD);
  static const Color lightOutline = Color(0xFFBDBDBD);

  // Dark theme colors
  static const Color darkPrimary = Color(0xFFBB86FC);
  static const Color darkPrimaryVariant = Color(0xFF3700B3);
  static const Color darkSecondary = Color(0xFF03DAC6);
  static const Color darkSecondaryVariant = Color(0xFF03DAC6);
  
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  
  static const Color darkOnPrimary = Colors.black;
  static const Color darkOnSecondary = Colors.black;
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white;
  static const Color darkOnSurfaceVariant = Color(0xFFBBBBBB);
  
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnError = Colors.black;
  static const Color darkSuccess = Color(0xFF81C784);
  static const Color darkWarning = Color(0xFFFFB74D);
  
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkOutline = Color(0xFF424242);
}

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.lightPrimary,
    primaryContainer: AppColors.lightPrimaryVariant,
    secondary: AppColors.lightSecondary,
    secondaryContainer: AppColors.lightSecondaryVariant,
    surface: AppColors.lightSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    background: AppColors.lightBackground,
    error: AppColors.lightError,
    onPrimary: AppColors.lightOnPrimary,
    onSecondary: AppColors.lightOnSecondary,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    onBackground: AppColors.lightOnBackground,
    onError: AppColors.lightOnError,
    outline: AppColors.lightOutline,
  ),
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightOnSurface,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.lightOnSurface),
    displayMedium: TextStyle(color: AppColors.lightOnSurface),
    displaySmall: TextStyle(color: AppColors.lightOnSurface),
    headlineLarge: TextStyle(color: AppColors.lightOnSurface),
    headlineMedium: TextStyle(color: AppColors.lightOnSurface),
    headlineSmall: TextStyle(color: AppColors.lightOnSurface),
    titleLarge: TextStyle(color: AppColors.lightOnSurface),
    titleMedium: TextStyle(color: AppColors.lightOnSurface),
    titleSmall: TextStyle(color: AppColors.lightOnSurface),
    bodyLarge: TextStyle(color: AppColors.lightOnSurface),
    bodyMedium: TextStyle(color: AppColors.lightOnSurface),
    bodySmall: TextStyle(color: AppColors.lightOnSurfaceVariant),
    labelLarge: TextStyle(color: AppColors.lightOnSurface),
    labelMedium: TextStyle(color: AppColors.lightOnSurface),
    labelSmall: TextStyle(color: AppColors.lightOnSurfaceVariant),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.lightOnSurfaceVariant),
    hintStyle: const TextStyle(color: AppColors.lightOnSurfaceVariant),
    prefixIconColor: AppColors.lightOnSurfaceVariant,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightOnPrimary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  cardTheme: CardTheme(
    color: AppColors.lightSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.lightDivider,
    thickness: 1,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkPrimary,
    primaryContainer: AppColors.darkPrimaryVariant,
    secondary: AppColors.darkSecondary,
    secondaryContainer: AppColors.darkSecondaryVariant,
    surface: AppColors.darkSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    background: AppColors.darkBackground,
    error: AppColors.darkError,
    onPrimary: AppColors.darkOnPrimary,
    onSecondary: AppColors.darkOnSecondary,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    onBackground: AppColors.darkOnBackground,
    onError: AppColors.darkOnError,
    outline: AppColors.darkOutline,
  ),
  scaffoldBackgroundColor: AppColors.darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkOnSurface,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.darkOnSurface),
    displayMedium: TextStyle(color: AppColors.darkOnSurface),
    displaySmall: TextStyle(color: AppColors.darkOnSurface),
    headlineLarge: TextStyle(color: AppColors.darkOnSurface),
    headlineMedium: TextStyle(color: AppColors.darkOnSurface),
    headlineSmall: TextStyle(color: AppColors.darkOnSurface),
    titleLarge: TextStyle(color: AppColors.darkOnSurface),
    titleMedium: TextStyle(color: AppColors.darkOnSurface),
    titleSmall: TextStyle(color: AppColors.darkOnSurface),
    bodyLarge: TextStyle(color: AppColors.darkOnSurface),
    bodyMedium: TextStyle(color: AppColors.darkOnSurface),
    bodySmall: TextStyle(color: AppColors.darkOnSurfaceVariant),
    labelLarge: TextStyle(color: AppColors.darkOnSurface),
    labelMedium: TextStyle(color: AppColors.darkOnSurface),
    labelSmall: TextStyle(color: AppColors.darkOnSurfaceVariant),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.darkOnSurfaceVariant),
    hintStyle: const TextStyle(color: AppColors.darkOnSurfaceVariant),
    prefixIconColor: AppColors.darkOnSurfaceVariant,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkOnPrimary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  cardTheme: CardTheme(
    color: AppColors.darkSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 1,
  ),
);