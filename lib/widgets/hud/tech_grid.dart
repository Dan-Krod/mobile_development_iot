import 'package:flutter/material.dart';

class TechGrid extends StatelessWidget {
  const TechGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: CustomPaint(
        painter: _BlueprintPainter(
          lineColor: theme.primaryColor.withValues(alpha: 0.05),
        ),
        child: Container(),
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final Color lineColor;
  _BlueprintPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    const double step = 60;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += step) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
