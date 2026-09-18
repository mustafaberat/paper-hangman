library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../game/daily_word.dart';
import '../game/hangman_round.dart';
import '../game/letters.dart';

class GameStore extends ChangeNotifier {
  GameStore();

  HangmanRound? round;
  String language = GameConfig.defaultLanguage;
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    language = prefs.getString(AppPrefsKeys.language) ??
        GameConfig.defaultLanguage;
    if (!GameConfig.supportedLanguages.contains(language)) {
      language = GameConfig.defaultLanguage;
    }

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
    round = current.guess(letter);
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
  }
}
