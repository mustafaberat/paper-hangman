library;

import 'package:flutter/material.dart';

import '../components/hangman_figure.dart';
import '../components/ink_button.dart';
import '../components/paper_page.dart';
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
        return PaperPage(
          child: store.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.ink),
                )
              : store.error != null
                  ? Center(child: Text(store.error!))
                  : _Menu(store: store),
        );
      },
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.store});

  final GameStore store;

  Future<void> _onPlay(BuildContext context) async {
    if (store.finished) {
      await store.startNewGame();
    }
    if (!context.mounted) return;
    await Navigator.pushNamed(context, AppRoutes.play);
  }

  @override
  Widget build(BuildContext context) {
    final lang = store.language;
    final round = store.round;
    final finished = store.finished;

    return Column(
      children: [
        const Spacer(),
        const SizedBox(
          height: 148,
          child: FittedBox(
            child: HangmanFigure(mistakes: 0),
          ),
        ),
        const SizedBox(height: AppDimens.spaceSmall),
        Text(
          AppStrings.appTitle(lang),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.tagline(lang),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (store.streak > 0) ...[
          const SizedBox(height: 4),
          Text(
            AppStrings.streakLine(store.streak, lang),
            style: const TextStyle(
              fontFamily: AppType.hand,
              color: AppColors.pen,
              fontSize: 18,
            ),
          ),
        ],
        if (finished && round != null) ...[
          const SizedBox(height: 8),
          Text(
            round.status == RoundStatus.won
                ? AppStrings.won(lang)
                : AppStrings.lost(lang),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppType.pen,
              color: round.status == RoundStatus.won
                  ? AppColors.pen
                  : AppColors.miss,
              fontSize: 26,
            ),
          ),
        ],
        const Spacer(),
        InkButton(
          label: store.playLabel,
          large: true,
          onTap: () => _onPlay(context),
        ),
        const SizedBox(height: AppDimens.spaceSmall),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          child: Text(
            AppStrings.settings(lang),
            style: const TextStyle(
              fontFamily: AppType.hand,
              color: AppColors.textMuted,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spaceLarge),
        Text(
          AppStrings.howToLines(lang),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
      ],
    );
  }
}
