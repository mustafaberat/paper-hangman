library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../game/daily_word.dart';
import '../game/hangman_round.dart';
import '../game/letters.dart';
import '../game/streak.dart';

class GameStore extends ChangeNotifier {
  GameStore();

  HangmanRound? round;
  String language = GameConfig.defaultLanguage;
  bool loading = true;
  String? error;
  bool resultSeen = false;
  int streak = 0;
  String? lastWinDay;

  bool get hasProgress =>
      round != null && round!.guessed.isNotEmpty && !round!.isWon && !round!.isLost;

  bool get finishedToday =>
      round != null && round!.status != RoundStatus.playing;

  String get playLabel {
    if (finishedToday) return AppStrings.seeToday(language);
    if (hasProgress) return AppStrings.continuePlay(language);
    return AppStrings.play(language);
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    language = prefs.getString(AppPrefsKeys.language) ??
        GameConfig.defaultLanguage;
    if (!GameConfig.supportedLanguages.contains(language)) {
      language = GameConfig.defaultLanguage;
    }
    streak = prefs.getInt(AppPrefsKeys.streak) ?? 0;
    lastWinDay = prefs.getString(AppPrefsKeys.lastWinDay);

    final daily = await pickDailyWord(language: language);
    if (daily == null) {
      error = AppStrings.emptyList(language);
      loading = false;
      notifyListeners();
      return;
    }

    final savedDay = prefs.getString(AppPrefsKeys.dayKey);
    final savedGuesses = prefs.getStringList(AppPrefsKeys.guesses) ?? [];
    final sameDay = savedDay == '${daily.dayKey}|$language';

    round = HangmanRound(
      word: daily.word,
      language: language,
      dayKey: daily.dayKey,
      guessed: sameDay
          ? savedGuesses.map((g) => foldLetter(g, language)).toSet()
          : <String>{},
    );
    resultSeen = sameDay &&
        prefs.getString(AppPrefsKeys.resultSeen) == '${daily.dayKey}|$language';
    loading = false;
    error = null;
    notifyListeners();
    await _persist();
  }

  Future<void> setLanguage(String code) async {
    if (!GameConfig.supportedLanguages.contains(code)) return;
    language = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppPrefsKeys.language, code);
    await load();
  }

  Future<void> guess(String letter) async {
    final current = round;
    if (current == null || !current.canGuess(letter)) return;
    final next = current.guess(letter);
    if (current.status == RoundStatus.playing &&
        next.status != RoundStatus.playing) {
      final update = nextStreak(
        won: next.isWon,
        today: next.dayKey,
        lastWinDay: lastWinDay,
        streak: streak,
      );
      streak = update.streak;
      lastWinDay = update.lastWinDay;
      resultSeen = false;
    }
    round = next;
    notifyListeners();
    await _persist();
  }

  Future<void> markResultSeen() async {
    final current = round;
    if (current == null) return;
    resultSeen = true;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final current = round;
    if (current == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppPrefsKeys.dayKey,
      '${current.dayKey}|${current.language}',
    );
    await prefs.setStringList(
      AppPrefsKeys.guesses,
      current.guessed.toList(),
    );
    await prefs.setInt(AppPrefsKeys.streak, streak);
    if (lastWinDay != null) {
      await prefs.setString(AppPrefsKeys.lastWinDay, lastWinDay!);
    }
    if (resultSeen) {
      await prefs.setString(
        AppPrefsKeys.resultSeen,
        '${current.dayKey}|${current.language}',
      );
    }
  }
}
