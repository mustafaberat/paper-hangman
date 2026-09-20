library;

import 'package:flutter/material.dart';

import '../components/paper_page.dart';
import '../config/app_config.dart';
import '../game/game_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.store, super.key});

  final GameStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final lang = store.language;
        return PaperPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: AppStrings.back(lang),
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                  ),
                  Text(
                    AppStrings.settings(lang),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spaceLarge),
              Text(
                AppStrings.language(lang),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppDimens.spaceSmall),
              Row(
                children: [
                  for (final code in GameConfig.supportedLanguages)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _LangChoice(
                        label: AppStrings.languageName(code, lang),
                        selected: store.language == code,
                        onTap: () => store.setLanguage(code),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimens.spaceLarge),
              Text(
                AppStrings.howTo(lang),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppDimens.spaceXSmall),
              Text(
                AppStrings.howToLines(lang),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Center(
                child: Text(
                  AppStrings.versionLine(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LangChoice extends StatelessWidget {
  const _LangChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.pen : AppColors.ink.withValues(alpha: 0.35),
            width: 1.6,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppType.hand,
            color: selected ? AppColors.pen : AppColors.ink,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
