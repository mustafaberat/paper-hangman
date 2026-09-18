library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// Kareli okul defteri zemini.
class NotebookPaper extends StatelessWidget {
  const NotebookPaper({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _PaperPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.paper);

    final grid = Paint()
      ..color = AppColors.grid
      ..strokeWidth = 1
      ..isAntiAlias = false;

    const step = AppDimens.grid;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final margin = Paint()
      ..color = AppColors.margin.withValues(alpha: 0.72)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(AppDimens.marginX, 0),
      Offset(AppDimens.marginX, size.height),
      margin,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
