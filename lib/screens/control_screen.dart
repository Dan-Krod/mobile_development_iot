import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('MANUAL OVERRIDE')),
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

                _buildModeSelector(),

                const SizedBox(height: 30),

                ControlToggle(
                  label: 'Main System Unit',
                  icon: Icons.power_rounded,
                  value: _systemPower,
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
                  isDisabled: !_systemPower || _isAutoMode,
                  onChanged: (val) => setState(() => _pumpState = val),
                ),

                ControlToggle(
                  label: 'Solenoid Valve',
                  icon: Icons.water_drop_outlined,
                  value: _valveState,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _modeButton('MANUAL', !_isAutoMode),
          _modeButton('AUTOMATION', _isAutoMode),
        ],
      ),
    );
  }

  Widget _modeButton(String title, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isAutoMode = title == 'AUTOMATION'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).primaryColor : Colors.transparent,
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
