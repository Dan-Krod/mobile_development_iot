import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final bool isOnline;
  const HomeHeader({required this.isOnline, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOnline ? Icons.radar_rounded : Icons.wifi_off_rounded,
                color: isOnline ? Colors.white24 : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'SMART FLUID MANAGEMENT',
                style: TextStyle(
                  color: isOnline
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.redAccent,
                  letterSpacing: 4,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isOnline ? 'DISPATCHER CENTER' : 'OFFLINE MODE : LOCAL DATA ONLY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isOnline
                  ? Colors.white38
                  : Colors.redAccent.withValues(alpha: 0.5),
              letterSpacing: 8,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
