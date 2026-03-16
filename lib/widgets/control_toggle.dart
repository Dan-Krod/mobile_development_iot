import 'package:flutter/material.dart';

class ControlToggle extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final void Function(bool) onChanged;
  final bool isDisabled;

  const ControlToggle({
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
    super.key,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.primaryColor;

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? activeColor.withValues(alpha: 0.3) : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value
                    ? activeColor.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value ? activeColor : Colors.white24,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDisabled
                        ? 'LOCKED BY SYSTEM'
                        : (value ? 'RUNNING / OPEN' : 'STOPPED / CLOSED'),
                    style: TextStyle(
                      color: value && !isDisabled
                          ? activeColor
                          : Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: isDisabled ? null : onChanged,
              activeThumbColor: activeColor,
              activeTrackColor: activeColor.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
