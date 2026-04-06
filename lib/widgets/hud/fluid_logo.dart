import 'package:flutter/material.dart';

class FluidLogo extends StatelessWidget {
  final double size;
  const FluidLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        Icon(
          Icons.opacity_rounded,
          size: size * 0.6,
          color: theme.primaryColor,
        ),
        SizedBox(
          width: size * 0.8,
          height: size * 0.8,
          child: CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 2,
            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
