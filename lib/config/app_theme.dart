library;

import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData get paper {
    const colors = ColorScheme.light(
      surface: AppColors.paper,
      primary: AppColors.ink,
      onPrimary: AppColors.paper,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppType.hand,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.paper,
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: AppType.pen,
          color: AppColors.ink,
          fontWeight: AppType.displayWeight,
          fontSize: AppType.display,
          height: 1,
        ),
        titleLarge: TextStyle(
          fontFamily: AppType.hand,
          color: AppColors.ink,
          fontWeight: AppType.titleWeight,
          fontSize: AppType.title,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppType.hand,
          color: AppColors.ink,
          fontWeight: AppType.bodyWeight,
          fontSize: AppType.body,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppType.hand,
          color: AppColors.textMuted,
          fontWeight: AppType.bodyWeight,
          fontSize: AppType.body,
        ),
      ),
    );
  }
}
