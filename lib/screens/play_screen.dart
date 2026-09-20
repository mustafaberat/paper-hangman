library;

import 'package:flutter/material.dart';

import '../components/hangman_figure.dart';
import '../components/letter_keyboard.dart';
import '../components/paper_page.dart';
import '../components/result_dialog.dart';
import '../components/word_slots.dart';
import '../config/app_config.dart';
import '../game/game_store.dart';
import '../game/hangman_round.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({required this.store, super.key});

  final GameStore store;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowResult());
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    _maybeShowResult();
    if (mounted) setState(() {});
  }

  Future<void> _maybeShowResult() async {
    final round = widget.store.round;
    if (!mounted || _dialogOpen || round == null) return;
    if (round.status == RoundStatus.playing || widget.store.resultSeen) {
      return;
    }

    _dialogOpen = true;
    await showResultDialog(context: context, round: round);
    await widget.store.markResultSeen();
    if (mounted) Navigator.pop(context);
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    if (store.loading || store.round == null) {
      return const PaperPage(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
      );
    }

    final round = store.round!;
    return PaperPage(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: AppStrings.back(store.language),
                icon: const Icon(Icons.arrow_back, color: AppColors.ink),
              ),
              Expanded(
                child: Text(
                  AppStrings.remaining(round.remaining, store.language),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
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
        ],
      ),
    );
  }
}
