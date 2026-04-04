import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/auth_cubit.dart';
import 'package:mobile_development_iot/cubits/mqtt_cubit.dart';

class AdminOverrideDialog extends StatefulWidget {
  const AdminOverrideDialog({super.key});

  @override
  State<AdminOverrideDialog> createState() => _AdminOverrideDialogState();
}

class _AdminOverrideDialogState extends State<AdminOverrideDialog> {
  late double startH;
  late double endH;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      startH = authState.startHour.toDouble();
      endH = authState.endHour.toDouble();
    } else {
      startH = 10.0;
      endH = 22.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          SizedBox(width: 10),
          Text(
            'ADMIN OVERRIDE',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SYSTEM BOOT: ${startH.toInt()}:00',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: startH,
            max: 23,
            divisions: 23,
            activeColor: Colors.blueAccent,
            onChanged: (val) {
              if (val < endH) setState(() => startH = val);
            },
          ),
          const SizedBox(height: 20),
          Text(
            'SYSTEM HALT: ${endH.toInt()}:00',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: endH,
            min: 1,
            max: 24,
            divisions: 23,
            activeColor: Colors.redAccent,
            onChanged: (val) {
              if (val > startH) setState(() => endH = val);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () {
            debugPrint('👉 Натиснуто кнопку ENGAGE PROTOCOL');

            context.read<AuthCubit>().updateOperationalHours(
              startH.toInt(),
              endH.toInt(),
            );

            context.read<MqttCubit>().setOperationalHours(
              startH.toInt(),
              endH.toInt(),
            );

            Navigator.pop(context);
          },
          child: const Text(
            'ENGAGE PROTOCOL',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
