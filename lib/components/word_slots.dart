library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../game/hangman_round.dart';

class WordSlots extends StatelessWidget {
  const WordSlots({required this.round, super.key});

  final HangmanRound round;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: AppDimens.spaceSmall,
      children: [
        for (var i = 0; i < round.letters.length; i++)
          _Slot(
            text: round.slotAt(i),
            guessed: round.guessed.contains(round.letters[i]),
            lost: round.status == RoundStatus.lost,
          ),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.text,
    required this.guessed,
    required this.lost,
  });

  final String text;
  final bool guessed;
  final bool lost;

  @override
  Widget build(BuildContext context) {
    final missed = lost && text.isNotEmpty && !guessed;
    return SizedBox(
      width: AppDimens.letterSlotWidth,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppType.pen,
                  color: missed ? AppColors.miss : AppColors.pen,
                  fontSize: AppType.slot,
                  fontWeight: AppType.slotWeight,
                  height: 1,
                ),
              ),
            ),
          ),
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: (missed ? AppColors.miss : AppColors.pen)
                  .withValues(alpha: text.isEmpty ? 0.45 : 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
