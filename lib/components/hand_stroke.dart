library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Defter kâğıdına benzer hafif titrek çizgi.
abstract final class HandStroke {
  static Path line(
    Offset a,
    Offset b, {
    int seed = 1,
    double wobble = 1.05,
  }) {
    final path = Path()..moveTo(a.dx, a.dy);
    final delta = b - a;
    final len = delta.distance;
    if (len < 1) {
      path.lineTo(b.dx, b.dy);
      return path;
    }

    final dir = delta / len;
    final normal = Offset(-dir.dy, dir.dx);
    final waves = (len / 22).clamp(2.0, 6.0);
    final steps = (len / 7).clamp(5, 28).round();

    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final edge = (i == 1 || i == steps) ? 0.0 : 1.0;
      final w = math.sin(t * math.pi * waves + seed) * wobble * edge;
      final jitter = math.sin(t * 13 + seed * 2.1) * wobble * 0.22 * edge;
      final p = a + delta * t + normal * (w + jitter);
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  static Path circle(Offset center, double radius, {int seed = 2}) {
    const steps = 40;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = t * math.pi * 2;
      final wob = 1 + math.sin(angle * 3 + seed) * 0.035;
      final p = Offset(
        center.dx + math.cos(angle) * radius * wob,
        center.dy + math.sin(angle) * radius * wob,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path;
  }

  static void drawLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    int seed = 1,
    double wobble = 1.05,
  }) {
    canvas.drawPath(line(a, b, seed: seed, wobble: wobble), paint);
  }

  static void drawCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    int seed = 2,
  }) {
    canvas.drawPath(circle(center, radius, seed: seed), paint);
  }
}
