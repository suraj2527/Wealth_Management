import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Roboto',
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.scaffoldLight,
    hintColor: AppColors.hintLight,
    dividerColor: AppColors.dividerLight,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.fieldLight,
    ),
    cardColor: AppColors.cardLight,
    colorScheme: ColorScheme.light(
      primary: AppColors.buttonLight,
      onPrimary: AppColors.buttonTextLight,
      secondaryContainer: AppColors.successLight,
      error: AppColors.errorLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Roboto',
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.scaffoldDark,
    hintColor: AppColors.hintDark,
    dividerColor: AppColors.dividerDark,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.fieldDark,
    ),
    cardColor: AppColors.cardDark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.buttonDark,
      onPrimary: AppColors.buttonTextDark,
      secondaryContainer: AppColors.successDark,
      error: AppColors.errorDark,
    ),
  );
}
