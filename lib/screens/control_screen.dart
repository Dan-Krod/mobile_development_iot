import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/control_toggle.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _systemPower = true;
  bool _pumpState = false;
  bool _valveState = false;
  bool _isAutoMode = false;

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments;

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('ERROR: No data received via Navigator')),
      );
    }

    final tank = args as TankModel;
    final primaryColor = Color(tank.colorValue);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(
          '${tank.title} OVERRIDE',
          style: const TextStyle(fontSize: 12, letterSpacing: 3),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SYSTEM CONFIGURATION',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                _buildModeSelector(primaryColor),

                const SizedBox(height: 30),

                ControlToggle(
                  label: 'Main System Unit',
                  icon: Icons.power_rounded,
                  value: _systemPower,
                  activeColor: primaryColor,
                  onChanged: (val) => setState(() => _systemPower = val),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white10, thickness: 1),
                ),

                ControlToggle(
                  label: 'Water Pump Station',
                  icon: Icons.settings_input_component_rounded,
                  value: _pumpState,
                  activeColor: primaryColor,
                  isDisabled: !_systemPower || _isAutoMode,
                  onChanged: (val) => setState(() => _pumpState = val),
                ),

                ControlToggle(
                  label: 'Solenoid Valve',
                  icon: Icons.water_drop_outlined,
                  value: _valveState,
                  activeColor: primaryColor,
                  isDisabled: !_systemPower || _isAutoMode,
                  onChanged: (val) => setState(() => _valveState = val),
                ),

                const Spacer(),

                ActionButton(
                  text: 'EMERGENCY SHUTDOWN',
                  onPressed: () => setState(() {
                    _pumpState = false;
                    _valveState = false;
                    _systemPower = false;
                  }),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(Color activeColor) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _modeButton('MANUAL', !_isAutoMode, activeColor),
          _modeButton('AUTOMATION', _isAutoMode, activeColor),
        ],
      ),
    );
  }

  Widget _modeButton(String title, bool active, Color activeColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isAutoMode = title == 'AUTOMATION'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
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
