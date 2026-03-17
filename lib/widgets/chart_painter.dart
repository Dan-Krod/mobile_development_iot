import 'package:flutter/material.dart';


class AdvancedChartPainter extends CustomPainter {
  final Color lineColor;
  final Color areaColor;

  AdvancedChartPainter({required this.lineColor, required this.areaColor});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = areaColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      final double y = size.height * (i / 6);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.85,
      size.width * 0.4,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.8,
      size.height * 0.7,
      size.width * 0.9,
      size.height * 0.2,
      size.width,
      size.height * 0.4,
    );

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
