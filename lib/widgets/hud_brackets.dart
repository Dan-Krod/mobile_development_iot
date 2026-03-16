import 'package:flutter/material.dart';

class HUDBrackets extends StatelessWidget {
  final Color color;
  const HUDBrackets({required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          _bracket(top: 15, left: 15, isTop: true, isLeft: true),
          _bracket(top: 15, right: 15, isTop: true, isLeft: false),
          _bracket(bottom: 15, left: 15, isTop: false, isLeft: true),
          _bracket(bottom: 15, right: 15, isTop: false, isLeft: false),
        ],
      ),
    );
  }

  Widget _bracket({
    required bool isTop,
    required bool isLeft,
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(color: color.withValues(alpha: 0.3), width: 2)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: color.withValues(alpha: 0.3), width: 2)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: color.withValues(alpha: 0.3), width: 2)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: color.withValues(alpha: 0.3), width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
