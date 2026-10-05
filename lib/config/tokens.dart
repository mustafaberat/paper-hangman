/// Hangman — görünür ve yapısal sabitler.
library;

import 'package:flutter/material.dart';

abstract final class AppIdentity {
  /// Play / launcher display name (package stays com.arusoft.hangdaily).
  static const String appName = 'Paper Hangman';
  static const String developer = 'ARU SOFT';
  static const String packageId = 'com.arusoft.hangdaily';
  static const String version = '2.1.0';
}

abstract final class AppRoutes {
  static const String home = '/';
  static const String play = '/play';
  static const String settings = '/settings';
}

abstract final class AppPrefsKeys {
  static const String language = 'language';
  /// Stores `roundId|language` for the active/last round.
  static const String dayKey = 'day_key';
  static const String activeWord = 'active_word';
  static const String guesses = 'guesses';
  static const String streak = 'streak';
  static const String resultSeen = 'result_seen';
}

abstract final class AppColors {
  static const Color paper = Color(0xFFF7F3E8);
  static const Color background = paper;
  static const Color grid = Color(0xFFB7CDD8);
  static const Color margin = Color(0xFFE15B5B);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color text = ink;
  static const Color textMuted = Color(0xFF6E675C);
  static const Color gallows = ink;
  static const Color figure = ink;
  static const Color pen = Color(0xFF1E44D6);
  static const Color miss = Color(0xFFC62828);
  static const Color hit = Color(0xFF2E7D32);
  static const Color keyFill = Color(0xE6FBF8F0);
  static const Color keyIdle = keyFill;
  static const Color keyUsed = Color(0x99FBF8F0);
  static const Color transparent = Color(0x00000000);
}

abstract final class AppDimens {
  static const double pagePadding = 22;
  static const double spaceXSmall = 8;
  static const double spaceSmall = 12;
  static const double spaceMedium = 16;
  static const double spaceLarge = 24;
  static const double minTouchTarget = 44;
  static const double keyHeight = 44;
  static const double keyRadius = 6;
  static const double letterSlotWidth = 42;
  static const double hangmanSize = 268;
  static const double playMaxWidth = 430;
  static const double stroke = 5;
  static const double grid = 22;
  static const double marginX = 18;
}

abstract final class AppType {
  static const String hand = 'PatrickHand';
  static const String pen = 'Caveat';
  static const double display = 34;
  static const double title = 20;
  static const double body = 18;
  static const double key = 20;
  static const double slot = 42;
  static const FontWeight displayWeight = FontWeight.w700;
  static const FontWeight titleWeight = FontWeight.w400;
  static const FontWeight bodyWeight = FontWeight.w400;
  static const FontWeight slotWeight = FontWeight.w700;
}

abstract final class AppMotion {
  static const Duration figureStep = Duration(milliseconds: 280);
}
