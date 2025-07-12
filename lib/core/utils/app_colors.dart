import 'package:flutter/material.dart';

class AppColors {
// Light theme colors
static const Color lightPrimary = Color(0xFF6750A4); // Material 3 purple
static const Color lightPrimaryContainer = Color(0xFFEADDFF);
static const Color lightSecondary = Color(0xFF625B71);
static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
static const Color lightSurface = Color(0xFFFFFBFE);
static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
static const Color lightBackground = Color(0xFFFFFBFE);
static const Color lightOnPrimary = Colors.white;
static const Color lightOnPrimaryContainer = Color(0xFF21005D);
static const Color lightOnSecondary = Colors.white;
static const Color lightOnSecondaryContainer = Color(0xFF1D192B);
static const Color lightOnSurface = Color(0xFF1C1B1F);
static const Color lightOnSurfaceVariant = Color(0xFF49454F);
static const Color lightOnBackground = Color(0xFF1C1B1F);
static const Color lightOutline = Color(0xFF79747E);
static const Color lightError = Color(0xFFBA1A1A);
static const Color lightOnError = Colors.white;

// Dark theme colors (keeping for future use)
static const Color darkPrimary = Color(0xFFD0BCFF);
static const Color darkOnPrimary = Color(0xFF381E72);
static const Color darkBackground = Color(0xFF10131C);
static const Color darkOnBackground = Color(0xFFE6E0E9);
static const Color darkError = Color(0xFFFFB4AB);
static const Color darkOnError = Color(0xFF690005);
}

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    primaryContainer: AppColors.lightPrimaryContainer,
    onPrimaryContainer: AppColors.lightOnPrimaryContainer,
    secondary: AppColors.lightSecondary,
    onSecondary: AppColors.lightOnSecondary,
    secondaryContainer: AppColors.lightSecondaryContainer,
    onSecondaryContainer: AppColors.lightOnSecondaryContainer,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    background: AppColors.lightBackground,
    onBackground: AppColors.lightOnBackground,
    outline: AppColors.lightOutline,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
  ),
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightPrimary,
    foregroundColor: AppColors.lightOnPrimary,
    elevation: 2,
    surfaceTintColor: AppColors.lightPrimary,
  ),
  cardTheme: CardTheme(
    color: AppColors.lightSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.lightOnBackground),
    bodyMedium: TextStyle(color: AppColors.lightOnBackground),
    bodySmall: TextStyle(color: AppColors.lightOnSurfaceVariant),
    headlineLarge: TextStyle(color: AppColors.lightOnBackground),
    headlineMedium: TextStyle(color: AppColors.lightOnBackground),
    headlineSmall: TextStyle(color: AppColors.lightOnBackground),
    titleLarge: TextStyle(color: AppColors.lightOnBackground),
    titleMedium: TextStyle(color: AppColors.lightOnBackground),
    titleSmall: TextStyle(color: AppColors.lightOnBackground),
  ),
  inputDecorationTheme: InputDecorationTheme(
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
    fillColor: AppColors.lightSurfaceVariant,
    labelStyle: const TextStyle(color: AppColors.lightOnSurfaceVariant),
    hintStyle: const TextStyle(color: AppColors.lightOnSurfaceVariant),
    prefixIconColor: AppColors.lightOnSurfaceVariant,
    suffixIconColor: AppColors.lightOnSurfaceVariant,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.lightOnPrimary,
      backgroundColor: AppColors.lightPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.lightPrimary,
      side: const BorderSide(color: AppColors.lightOutline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.lightPrimary,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.lightPrimary,
    foregroundColor: AppColors.lightOnPrimary,
  ),
);

ThemeData darkTheme = ThemeData(
  primaryColor: AppColors.darkPrimary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    background: AppColors.darkBackground,
    onBackground: AppColors.darkOnBackground,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
  ),
  scaffoldBackgroundColor: AppColors.darkBackground,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.darkOnBackground),
  ),
  inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: AppColors.darkOnBackground),
      prefixIconColor: AppColors.darkOnBackground
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.darkOnPrimary,
      backgroundColor: AppColors.darkPrimary,
    ),
  ),
);