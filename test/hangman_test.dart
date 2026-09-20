import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/config/game_config.dart';
import 'package:hangman/game/daily_word.dart';
import 'package:hangman/game/hangman_round.dart';
import 'package:hangman/game/letters.dart';
import 'package:hangman/game/streak.dart';

void main() {
  test('daily index is stable for a day and language', () {
    final a = dailyIndex(dayKey: '2026-09-17', language: 'tr', length: 14);
    final b = dailyIndex(dayKey: '2026-09-17', language: 'tr', length: 14);
    final c = dailyIndex(dayKey: '2026-09-18', language: 'tr', length: 14);
    final d = dailyIndex(dayKey: '2026-09-17', language: 'en', length: 14);
    expect(a, b);
    expect(a, isNot(c));
    expect(a, isNot(d));
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
      dayKey: '2026-09-17',
    );
    const misses = ['e', 'r', 't', 'y', 'u', 'o'];
    for (final m in misses) {
      round = round.guess(m);
    }
    expect(round.mistakes, GameConfig.maxMistakes);
    expect(round.status, RoundStatus.lost);
  });

  test('streak grows on consecutive wins and resets on a loss', () {
    final first = nextStreak(
      won: true,
      today: '2026-09-17',
      lastWinDay: null,
      streak: 0,
    );
    expect(first.streak, 1);
    final second = nextStreak(
      won: true,
      today: '2026-09-18',
      lastWinDay: first.lastWinDay,
      streak: first.streak,
    );
    expect(second.streak, 2);
    final lost = nextStreak(
      won: false,
      today: '2026-09-19',
      lastWinDay: second.lastWinDay,
      streak: second.streak,
    );
    expect(lost.streak, 0);
  });
}
