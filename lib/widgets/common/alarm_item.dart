import 'package:flutter/material.dart';

class AlarmItem extends StatelessWidget {
  final String time;
  final String message;
  final bool isCritical;

  const AlarmItem({
    required this.time,
    required this.message,
    super.key,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final alarmColor = isCritical
        ? const Color(0xFFF43F5E)
        : const Color.fromARGB(255, 253, 176, 75);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: alarmColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alarmColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: alarmColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCritical
                ? Icons.report_problem_rounded
                : Icons.info_outline_rounded,
            color: alarmColor,
            size: 24,
          ),
        ),
        title: Text(
          message.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isCritical
                ? alarmColor
                : Colors.white.withValues(alpha: 0.9),
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: Colors.white38,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                  fontFamily: 'Monospace',
                ),
              ),
              const Spacer(),
              if (isCritical)
                const Text(
                  'PRIORITY: HIGH',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
