library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'hand_stroke.dart';

class HangmanFigure extends StatelessWidget {
  const HangmanFigure({required this.mistakes, super.key});

  final int mistakes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimens.hangmanSize,
      height: AppDimens.hangmanSize,
      child: CustomPaint(
        painter: _GallowsPainter(
          mistakes: mistakes.clamp(0, GameConfig.maxMistakes),
        ),
      ),
    );
  }
}

class _GallowsPainter extends CustomPainter {
  _GallowsPainter({required this.mistakes});

  final int mistakes;

  Paint get _ink => Paint()
    ..color = AppColors.ink
    ..strokeWidth = AppDimens.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ink = _ink;

    final baseY = h * 0.90;
    final poleX = w * 0.30;
    final topY = h * 0.10;
    final beamX = w * 0.78;
    final ropeX = w * 0.74;
    final ropeY = h * 0.20;

    HandStroke.drawLine(
      canvas,
      Offset(w * 0.14, baseY),
      Offset(w * 0.52, baseY),
      ink,
      seed: 3,
      wobble: 0.7,
    );
    HandStroke.drawLine(
      canvas,
      Offset(poleX, baseY),
      Offset(poleX, topY),
      ink,
      seed: 5,
      wobble: 0.85,
    );
    HandStroke.drawLine(
      canvas,
      Offset(poleX, topY),
      Offset(beamX, topY),
      ink,
      seed: 8,
      wobble: 0.7,
    );
    HandStroke.drawLine(
      canvas,
      Offset(poleX, h * 0.28),
      Offset(w * 0.48, topY),
      ink,
      seed: 11,
      wobble: 0.8,
    );
    HandStroke.drawLine(
      canvas,
      Offset(ropeX, topY),
      Offset(ropeX, ropeY),
      ink,
      seed: 13,
      wobble: 0.45,
    );

    final headR = h * 0.075;
    final headC = Offset(ropeX, ropeY + headR);
    final neck = Offset(ropeX, ropeY + headR * 2);
    final hip = Offset(ropeX, h * 0.58);
    final chest = Offset(ropeX, h * 0.42);

    if (mistakes >= 1) {
      HandStroke.drawCircle(canvas, headC, headR, ink, seed: 17);
    }
    if (mistakes >= 2) {
      HandStroke.drawLine(canvas, neck, hip, ink, seed: 19, wobble: 0.7);
    }
    if (mistakes >= 3) {
      HandStroke.drawLine(
        canvas,
        chest,
        Offset(ropeX - w * 0.16, h * 0.54),
        ink,
        seed: 23,
        wobble: 0.75,
      );
    }
    if (mistakes >= 4) {
      HandStroke.drawLine(
        canvas,
        chest,
        Offset(ropeX + w * 0.16, h * 0.54),
        ink,
        seed: 29,
        wobble: 0.75,
      );
    }
    if (mistakes >= 5) {
      HandStroke.drawLine(
        canvas,
        hip,
        Offset(ropeX - w * 0.15, h * 0.78),
        ink,
        seed: 31,
        wobble: 0.8,
      );
    }
    if (mistakes >= 6) {
      HandStroke.drawLine(
        canvas,
        hip,
        Offset(ropeX + w * 0.15, h * 0.78),
        ink,
        seed: 37,
        wobble: 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GallowsPainter oldDelegate) {
    return oldDelegate.mistakes != mistakes;
  }
}
