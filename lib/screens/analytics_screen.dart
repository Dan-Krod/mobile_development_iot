import 'package:flutter/material.dart';
import 'package:mobile_development_iot/widgets/tech_grid.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORICAL DATA'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const TechGrid(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SENSOR TRENDS (LAST 24H)',
                      style: TextStyle(
                        color: Colors.white54, 
                        letterSpacing: 2, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Icon(Icons.history_toggle_off_rounded, color: theme.primaryColor, size: 16),
                  ],
                ),
                const SizedBox(height: 25),
                
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color?.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: AdvancedChartPainter(
                          lineColor: theme.primaryColor,
                          areaColor: theme.primaryColor.withOpacity(0.1),
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                _buildLegendCard(
                  'FLUID LEVEL MONITORING', 
                  '31.0%', 
                  theme.primaryColor, 
                  Icons.waves_rounded
                ),
                const SizedBox(height: 12),
                _buildLegendCard(
                  'MOTOR TEMPERATURE', 
                  '24.57 °C', 
                  Colors.orangeAccent, 
                  Icons.thermostat_rounded
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const Spacer(),
          Text(
            value, 
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'Monospace')
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24),
        ],
      ),
    );
  }
}

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
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      final double y = size.height * (i / 6);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.2, size.height * 0.85, 
      size.width * 0.4, size.height * 0.3, 
      size.width * 0.6, size.height * 0.5
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.7, 
      size.width * 0.9, size.height * 0.2, 
      size.width, size.height * 0.4
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