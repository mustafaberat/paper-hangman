library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'notebook_paper.dart';

class PaperPage extends StatelessWidget {
  const PaperPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
