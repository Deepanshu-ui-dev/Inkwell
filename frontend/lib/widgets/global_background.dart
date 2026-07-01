import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:blog_app/utils/app_theme.dart';

class GlobalBackground extends StatelessWidget {
  final Widget child;
  const GlobalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _AppGridPainter(context.colors)),
          ),
        ),
        child,
      ],
    );
  }
}

class _AppGridPainter extends CustomPainter {
  final AppColorsExtension c;
  _AppGridPainter(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    // We want the pattern to be very subtle, depending on light/dark mode
    final isDark = c.background.computeLuminance() < 0.5;
    final dotColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : c.ink.withValues(alpha: 0.06);

    final paint = Paint()
      ..color = dotColor
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Draw a subtle plus (+) grid
    const step = 32.0;
    const sizePlus = 3.0; // half-length of the plus lines
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawLine(Offset(x - sizePlus, y), Offset(x + sizePlus, y), paint);
        canvas.drawLine(Offset(x, y - sizePlus), Offset(x, y + sizePlus), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AppGridPainter oldDelegate) {
    return oldDelegate.c.background != c.background;
  }
}
