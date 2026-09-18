library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../game/hangman_round.dart';
import '../game/letters.dart';

class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    required this.round,
    required this.onKey,
    super.key,
  });

  final HangmanRound round;
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final rows = GameConfig.keyboardFor(round.language);
    final maxLen = rows.fold<int>(0, (n, row) => math.max(n, row.runes.length));
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                if (row.runes.length < maxLen)
                  Spacer(flex: maxLen - row.runes.length),
                for (final rune in row.runes)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: _Key(
                        letter: String.fromCharCode(rune),
                        round: round,
                        onKey: onKey,
                      ),
                    ),
                  ),
                if (row.runes.length < maxLen)
                  Spacer(flex: maxLen - row.runes.length),
              ],
            ),
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.letter,
    required this.round,
    required this.onKey,
  });

  final String letter;
  final HangmanRound round;
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    final folded = foldLetter(letter, round.language);
    final used = round.guessed.contains(folded);
    final hit = used && round.letters.contains(folded);
    final miss = used && !hit;
    final enabled = round.canGuess(letter);
    final tilt = ((letter.codeUnitAt(0) % 5) - 2) * 0.018;

    Color fg = AppColors.ink;
    if (hit) fg = AppColors.pen;
    if (miss) fg = AppColors.miss;

    return Transform.rotate(
      angle: tilt,
      child: SizedBox(
        height: AppDimens.keyHeight,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: enabled ? () => onKey(letter) : null,
            borderRadius: BorderRadius.circular(AppDimens.keyRadius),
            child: CustomPaint(
              painter: _KeyFramePainter(
                ink: miss
                    ? AppColors.miss.withValues(alpha: 0.55)
                    : hit
                        ? AppColors.pen.withValues(alpha: 0.7)
                        : AppColors.ink.withValues(alpha: used ? 0.28 : 0.55),
                seed: letter.codeUnitAt(0),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontFamily: AppType.hand,
                    color: fg.withValues(alpha: miss ? 0.75 : 1),
                    fontSize: AppType.key,
                    height: 1,
                    decoration: miss ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.miss,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyFramePainter extends CustomPainter {
  _KeyFramePainter({required this.ink, required this.seed});

  final Color ink;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = 2.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final rng = math.Random(seed);
    final r = 5.0 + rng.nextDouble();

    final path = Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + r)
      ..lineTo(rect.right, rect.bottom - r)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - r, rect.bottom)
      ..lineTo(rect.left + r, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - r)
      ..lineTo(rect.left, rect.top + r)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + r, rect.top);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _KeyFramePainter oldDelegate) {
    return oldDelegate.ink != ink;
  }
}
