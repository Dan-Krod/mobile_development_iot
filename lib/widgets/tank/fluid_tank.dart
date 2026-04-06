import 'package:flutter/material.dart';

class FluidTank extends StatelessWidget {
  final double level;
  final bool isPumpActive;

  const FluidTank({required this.level, super.key, this.isPumpActive = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = isPumpActive ? theme.primaryColor : Colors.white10;

    return SizedBox(
      width: 300,
      height: 400,
      child: Stack(
        children: [
          Positioned(
            bottom: 85,
            right: 45,
            child: Container(
              width: 85,
              height: 15,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[900]!,
                    const Color.fromARGB(255, 31, 31, 31),
                    Colors.grey[800]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Positioned(left: 10, bottom: 20, child: _buildGlassTank(theme)),

          Positioned(
            bottom: 40,
            right: 5,
            child: _buildAdvancedPump(statusColor, isPumpActive),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTank(ThemeData theme) {
    return Container(
      width: 160,
      height: 340,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              width: double.infinity,
              height: 320 * level,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryColor.withValues(alpha: 0.7),
                    theme.primaryColor.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
            _buildMeasurementTicks(),
            Center(
              child: Text(
                '${(level * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedPump(Color color, bool active) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 30,
          height: 4,
          decoration: BoxDecoration(
            color: active ? color : const Color.fromARGB(255, 219, 34, 34),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(255, 109, 123, 145),
            border: Border.all(
              color: active
                  ? color.withValues(alpha: 0.5)
                  : const Color.fromARGB(26, 93, 93, 93),
              width: 2,
            ),
          ),
          child: Icon(
            active ? Icons.sync_rounded : Icons.power_settings_new_rounded,
            size: 32,
            color: active ? color : const Color.fromARGB(139, 26, 26, 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          active ? 'PUMP: RUN' : 'PUMP: OFF',
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementTicks() {
    return Positioned(
      right: 10,
      top: 20,
      bottom: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          7,
          (index) => Container(width: 8, height: 1, color: Colors.white10),
        ),
      ),
    );
  }
}
