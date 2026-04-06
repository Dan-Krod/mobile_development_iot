import 'package:flutter/material.dart';

class HUDCorner extends StatelessWidget {
  final double? top, left, right, bottom;
  final String title;
  final String value;
  final Color color;
  final bool hasPulse;

  const HUDCorner({
    required this.title,
    required this.value,
    required this.color,
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.hasPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Column(
        crossAxisAlignment: left != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasPulse) _buildHeartbeat(color),
              if (hasPulse) const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              fontFamily: 'Monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartbeat(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
