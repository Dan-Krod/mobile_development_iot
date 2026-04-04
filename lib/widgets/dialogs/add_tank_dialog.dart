import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/tank_cubit.dart';
import 'package:mobile_development_iot/models/tank_model.dart';

class AddTankDialog extends StatefulWidget {
  final bool hasHardwareNode;
  const AddTankDialog({required this.hasHardwareNode, super.key});

  @override
  State<AddTankDialog> createState() => _AddTankDialogState();
}

class _AddTankDialogState extends State<AddTankDialog> {
  final titleController = TextEditingController();
  final capacityController = TextEditingController();
  int selectedColor = 0xFF38BDF8;
  final formKey = GlobalKey<FormState>();
  late bool bindToHardware;

  @override
  void initState() {
    super.initState();
    bindToHardware = !widget.hasHardwareNode;
  }

  @override
  void dispose() {
    titleController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      title: const Text(
        'REGISTER NEW NODE',
        style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1),
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'NODE NAME',
                labelStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [0xFF10B981, 0xFFFACC15, 0xFFA855F7, 0xFFFB7185]
                  .map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => selectedColor = c),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: selectedColor == c
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 25),
            if (widget.hasHardwareNode)
              const Text(
                'HARDWARE ALREADY BOUND. Creating Virtual Node.',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BIND TO ESP32',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: bindToHardware,
                    activeThumbColor: Colors.green,
                    onChanged: (val) => setState(() => bindToHardware = val),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            final newTank = TankModel(
              id: DateTime.now().toString(),
              title: titleController.text.trim(),
              capacity: 100,
              currentLevel: 0.4,
              colorValue: selectedColor,
              isHardwareBound: bindToHardware,
            );
            context.read<TankCubit>().addTank(newTank);
            Navigator.pop(context);
          },
          child: const Text(
            'INSTALL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
