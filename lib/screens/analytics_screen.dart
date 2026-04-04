import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/widgets/tank/chart_painter.dart';
import 'package:mobile_development_iot/widgets/hud/tech_grid.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! TankModel) {
      Future.microtask(() {
        if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tank = args;
    final tankColor = Color(tank.colorValue);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(
          '${tank.title} ANALYTICS',
          style: const TextStyle(fontSize: 12, letterSpacing: 3),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.history_toggle_off_rounded,
                      color: tankColor,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color?.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: AdvancedChartPainter(
                          lineColor: tankColor,
                          areaColor: tankColor.withValues(alpha: 0.1),
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _buildLegendCard(
                  'FLUID LEVEL MONITORING',
                  '${(tank.currentLevel * 100).toInt()}%',
                  tankColor,
                  Icons.waves_rounded,
                ),
                const SizedBox(height: 12),
                _buildLegendCard(
                  'MOTOR TEMPERATURE',
                  '24.57 °C',
                  Colors.orangeAccent,
                  Icons.thermostat_rounded,
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monospace',
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }
}
