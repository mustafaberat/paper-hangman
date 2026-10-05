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

  bool get hasProgress =>
      round != null && round!.guessed.isNotEmpty && !round!.isWon && !round!.isLost;

  bool get finished =>
      round != null && round!.status != RoundStatus.playing;

  String get playLabel {
    if (finished) return AppStrings.playAgain(language);
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

    final savedKey = prefs.getString(AppPrefsKeys.dayKey);
    final savedGuesses = prefs.getStringList(AppPrefsKeys.guesses) ?? [];
    final savedWord = prefs.getString(AppPrefsKeys.activeWord);

    if (savedKey != null &&
        savedKey.endsWith('|$language') &&
        savedWord != null &&
        savedWord.isNotEmpty) {
      final roundId = savedKey.split('|').first;
      round = HangmanRound(
        word: savedWord,
        language: language,
        roundId: roundId,
        guessed: savedGuesses.map((g) => foldLetter(g, language)).toSet(),
      );
      resultSeen = prefs.getString(AppPrefsKeys.resultSeen) == savedKey;
      loading = false;
      error = null;
      notifyListeners();
      return;
    }

    await startNewGame(notifyLoading: false);
    loading = false;
    notifyListeners();
  }

  Future<void> startNewGame({bool notifyLoading = true}) async {
    if (notifyLoading) {
      loading = true;
      notifyListeners();
    }

    final picked = await pickWord(
      language: language,
      avoidWord: round?.word,
    );
    if (picked == null) {
      error = AppStrings.emptyList(language);
      round = null;
      if (notifyLoading) {
        loading = false;
        notifyListeners();
      }
      return;
    }

    round = HangmanRound(
      word: picked.word,
      language: language,
      roundId: picked.roundId,
    );
    resultSeen = false;
    error = null;
    if (notifyLoading) {
      loading = false;
      notifyListeners();
    }
    await _persist();
  }

  Future<void> setLanguage(String code) async {
    if (!GameConfig.supportedLanguages.contains(code)) return;
    language = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppPrefsKeys.language, code);
    await startNewGame();
  }

  Future<void> guess(String letter) async {
    final current = round;
    if (current == null || !current.canGuess(letter)) return;
    final next = current.guess(letter);
    if (current.status == RoundStatus.playing &&
        next.status != RoundStatus.playing) {
      streak = nextWinStreak(won: next.isWon, streak: streak);
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
    final key = '${current.roundId}|${current.language}';
    await prefs.setString(AppPrefsKeys.dayKey, key);
    await prefs.setString(AppPrefsKeys.activeWord, current.word);
    await prefs.setStringList(
      AppPrefsKeys.guesses,
      current.guessed.toList(),
    );
    await prefs.setInt(AppPrefsKeys.streak, streak);
    if (resultSeen) {
      await prefs.setString(AppPrefsKeys.resultSeen, key);
    } else {
      await prefs.remove(AppPrefsKeys.resultSeen);
    }
  }
}
