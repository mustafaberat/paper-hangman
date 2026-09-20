library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../game/hangman_round.dart';
import 'ink_button.dart';

Future<void> showResultDialog({
  required BuildContext context,
  required HangmanRound round,
}) {
  final won = round.status == RoundStatus.won;
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.ink.withValues(alpha: 0.28),
    builder: (context) {
      return Dialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.ink, width: 1.8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                won
                    ? AppStrings.won(round.language)
                    : AppStrings.lost(round.language),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppType.pen,
                  color: won ? AppColors.pen : AppColors.miss,
                  fontSize: 32,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.theWord(round.word.toUpperCase(), round.language),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppType.hand,
                  color: AppColors.ink,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 22),
              InkButton(
                label: AppStrings.ok(round.language),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}
