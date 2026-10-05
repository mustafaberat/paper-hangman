library;

import '../config/game_config.dart';
import 'letters.dart';

enum RoundStatus { playing, won, lost }

class HangmanRound {
  HangmanRound({
    required this.word,
    required this.language,
    required this.roundId,
    Set<String>? guessed,
  }) : guessed = guessed ?? <String>{};

  final String word;
  final String language;
  final String roundId;
  final Set<String> guessed;

  List<String> get letters => graphemes(word, language);

  int get mistakes {
    var n = 0;
    for (final g in guessed) {
      if (!letters.contains(g)) n++;
    }
    return n;
  }

  int get remaining => GameConfig.maxMistakes - mistakes;

  bool get isWon =>
      letters.isNotEmpty && letters.every(guessed.contains);

  bool get isLost => mistakes >= GameConfig.maxMistakes;

  RoundStatus get status {
    if (isWon) return RoundStatus.won;
    if (isLost) return RoundStatus.lost;
    return RoundStatus.playing;
  }

  bool canGuess(String raw) {
    if (status != RoundStatus.playing) return false;
    final letter = foldLetter(raw, language);
    if (letter.isEmpty) return false;
    return !guessed.contains(letter);
  }

  HangmanRound guess(String raw) {
    if (!canGuess(raw)) return this;
    return HangmanRound(
      word: word,
      language: language,
      roundId: roundId,
      guessed: {...guessed, foldLetter(raw, language)},
    );
  }

  String slotAt(int i) {
    final letter = letters[i];
    if (guessed.contains(letter) || isLost) return letter.toUpperCase();
    return '';
  }
}
