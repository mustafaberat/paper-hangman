import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/config/game_config.dart';
import 'package:hangman/game/daily_word.dart';
import 'package:hangman/game/hangman_round.dart';
import 'package:hangman/game/letters.dart';
import 'package:hangman/game/streak.dart';

void main() {
  test('pickWord avoids immediate repeat when possible', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final first = await pickWord(
      language: 'en',
      random: Random(1),
    );
    expect(first, isNotNull);
    final second = await pickWord(
      language: 'en',
      avoidWord: first!.word,
      random: Random(1),
    );
    expect(second, isNotNull);
    // Same seed would pick same index; avoidWord must shift it.
    expect(second!.word.toLowerCase(), isNot(first.word.toLowerCase()));
  });

  test('turkish dotted i folds correctly', () {
    expect(foldLetter('İ', 'tr'), 'i');
    expect(foldLetter('I', 'tr'), 'ı');
    expect(foldLetter('Ş', 'tr'), 'ş');
  });

  test('round ends at max mistakes', () {
    var round = HangmanRound(
      word: 'kal',
      language: 'tr',
      roundId: 'r-test',
    );
    const misses = ['e', 'r', 't', 'y', 'u', 'o'];
    for (final m in misses) {
      round = round.guess(m);
    }
    expect(round.mistakes, GameConfig.maxMistakes);
    expect(round.status, RoundStatus.lost);
  });

  test('win streak grows on wins and resets on a loss', () {
    expect(nextWinStreak(won: true, streak: 0), 1);
    expect(nextWinStreak(won: true, streak: 1), 2);
    expect(nextWinStreak(won: false, streak: 2), 0);
  });
}
