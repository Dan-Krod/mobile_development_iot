import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/providers/mqtt_provider.dart';
import 'package:mobile_development_iot/widgets/action_button.dart';
import 'package:mobile_development_iot/widgets/control_toggle.dart';
import 'package:provider/provider.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _localSystemPower = true;
  bool _localPumpState = false;
  bool _localValveState = false;

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
    final isHardware = tank.isHardwareBound;

    final mqtt = context.watch<MqttProvider>();

    final effectiveSysPower = isHardware
        ? mqtt.systemActive
        : _localSystemPower;
    final effectivePumpState = isHardware ? mqtt.pumpStatus : _localPumpState;
    final effectiveValveState = _localValveState;

    final isLockedByHardware = isHardware && mqtt.localOverride;
    final isDisconnected = isHardware && !mqtt.isConnected;

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
                if (!isHardware)
                  _buildInfoBanner(
                    'VIRTUAL MODE',
                    'Changes are simulated locally.',
                    Colors.purpleAccent,
                  ),
                if (isLockedByHardware)
                  _buildInfoBanner(
                    'HARDWARE LOCK',
                    'Physical override active on ESP32.',
                    Colors.redAccent,
                  ),
                if (isDisconnected)
                  _buildInfoBanner(
                    'OFFLINE',
                    'Connecting to MQTT Broker...',
                    Colors.orangeAccent,
                  ),

                const SizedBox(height: 10),
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
                  value: effectiveSysPower,
                  activeColor: primaryColor,
                  isDisabled: isLockedByHardware || isDisconnected,
                  onChanged: (val) {
                    if (isHardware) {
                      mqtt.sendCommand('system_status', val);
                    } else {
                      setState(() => _localSystemPower = val);
                    }
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white10, thickness: 1),
                ),

                ControlToggle(
                  label: 'Water Pump Station',
                  icon: Icons.settings_input_component_rounded,
                  value: effectivePumpState,
                  activeColor: primaryColor,
                  isDisabled:
                      isLockedByHardware ||
                      isDisconnected ||
                      !effectiveSysPower ||
                      _isAutoMode,
                  onChanged: (val) {
                    if (isHardware) {
                      mqtt.sendCommand('pump_command', val);
                    } else {
                      setState(() => _localPumpState = val);
                    }
                  },
                ),

                ControlToggle(
                  label: 'Solenoid Valve',
                  icon: Icons.water_drop_outlined,
                  value: effectiveValveState,
                  activeColor: primaryColor,
                  isDisabled:
                      isLockedByHardware ||
                      isDisconnected ||
                      !effectiveSysPower ||
                      _isAutoMode,
                  onChanged: (val) => setState(() => _localValveState = val),
                ),

                const Spacer(),

                ActionButton(
                  text: 'EMERGENCY SHUTDOWN',
                  onPressed: (isLockedByHardware || isDisconnected)
                      ? null
                      : () {
                          if (isHardware) {
                            mqtt.sendCommand('pump_command', false);
                            mqtt.sendCommand('system_status', false);
                          } else {
                            setState(() {
                              _localPumpState = false;
                              _localValveState = false;
                              _localSystemPower = false;
                            });
                          }
                        },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String title, String subtitle, Color color) {
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
                  subtitle,
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
