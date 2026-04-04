import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/control_cubit.dart';

class ModeSelector extends StatelessWidget {
  final Color activeColor;
  final bool isAuto;

  const ModeSelector({
    required this.activeColor,
    required this.isAuto,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ModeBtn(title: 'MANUAL', active: !isAuto, color: activeColor),
          _ModeBtn(title: 'AUTOMATION', active: isAuto, color: activeColor),
        ],
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String title;
  final bool active;
  final Color color;

  const _ModeBtn({
    required this.title,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<ControlCubit>().setAutoMode(title == 'AUTOMATION'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: active ? Colors.black : Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
