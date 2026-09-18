library;

import 'package:flutter/material.dart';

import '../components/hangman_figure.dart';
import '../components/letter_keyboard.dart';
import '../components/notebook_paper.dart';
import '../components/word_slots.dart';
import '../config/app_config.dart';
import '../game/game_store.dart';
import '../game/hangman_round.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.store, super.key});

  final GameStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.paper,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const NotebookPaper(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePadding,
                    AppDimens.spaceSmall,
                    AppDimens.pagePadding,
                    AppDimens.spaceMedium,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppDimens.playMaxWidth,
                      ),
                      child: store.loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.ink,
                              ),
                            )
                          : store.error != null
                              ? Center(child: Text(store.error!))
                              : _Play(store: store),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Play extends StatelessWidget {
  const _Play({required this.store});

  final GameStore store;

  @override
  Widget build(BuildContext context) {
    final round = store.round!;
    final status = round.status;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                AppStrings.titleFor(store.language),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            for (final code in GameConfig.supportedLanguages)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _LangChip(
                  code: code,
                  selected: store.language == code,
                  onTap: () => store.setLanguage(code),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            status == RoundStatus.won
                ? AppStrings.won(store.language)
                : status == RoundStatus.lost
                    ? AppStrings.lost(store.language)
                    : AppStrings.remaining(round.remaining, store.language),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HangmanFigure(mistakes: round.mistakes),
                const SizedBox(height: AppDimens.spaceMedium),
                WordSlots(round: round),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spaceMedium),
        LetterKeyboard(round: round, onKey: store.guess),
        const SizedBox(height: AppDimens.spaceMedium),
        Text(
          AppStrings.developerLine(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.languageLabel(code),
              style: TextStyle(
                fontFamily: AppType.hand,
                color: selected ? AppColors.pen : AppColors.textMuted,
                fontWeight: FontWeight.w400,
                fontSize: 18,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 22,
              height: 2.5,
              color: selected ? AppColors.pen : AppColors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
