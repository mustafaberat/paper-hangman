library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

class InkButton extends StatelessWidget {
  const InkButton({
    required this.label,
    required this.onTap,
    this.large = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.ink, width: 1.8),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: large ? 36 : 22,
              vertical: large ? 12 : 8,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: large ? AppType.pen : AppType.hand,
                color: AppColors.ink,
                fontSize: large ? 36 : 20,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
