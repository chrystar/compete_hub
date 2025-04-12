import 'package:flutter/material.dart';

class AppColors {
// Light theme colors
static const Color lightPrimary = Color(0xff222b45);
static const Color lightPrimaryText = Colors.white;
static const Color lightOnPrimary = Colors.white;
static const Color lightBackground = Colors.white;
static const Color lightOnBackground = Colors.black;
static const Color lightError = Colors.red;
static const Color lightOnError = Colors.white;

// Dark theme colors
static const Color darkPrimary = Color(0xFFBB86FC); // Example primary color
static const Color darkOnPrimary = Colors.black;
static const Color darkBackground = Color(0xFF121212); // Dark background
static const Color darkOnBackground = Colors.white;
static const Color darkError = Colors.red;
static const Color darkOnError = Colors.white;
}

ThemeData lightTheme = ThemeData(
  primaryColor: AppColors.lightPrimary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    background: AppColors.lightBackground,
    onBackground: AppColors.lightOnBackground,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
  ),
  scaffoldBackgroundColor: AppColors.lightBackground,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.lightOnBackground),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    labelStyle: TextStyle(color: AppColors.lightOnBackground),
    prefixIconColor: AppColors.lightOnBackground,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.lightOnPrimary,
      backgroundColor: AppColors.lightPrimary,
    ),
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