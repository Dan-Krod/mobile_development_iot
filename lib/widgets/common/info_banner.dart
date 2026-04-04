import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  final String title;
  final String sub;
  final Color color;

  const InfoBanner({
    required this.title,
    required this.sub,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
