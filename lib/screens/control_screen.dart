import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/control_cubit.dart';
import 'package:mobile_development_iot/cubits/mqtt_cubit.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/widgets/common/action_button.dart';
import 'package:mobile_development_iot/widgets/common/control_toggle.dart';
import 'package:mobile_development_iot/widgets/common/info_banner.dart';
import 'package:mobile_development_iot/widgets/tank/mode_selector.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tank = ModalRoute.of(context)?.settings.arguments as TankModel?;
    if (tank == null) {
      return const Scaffold(body: Center(child: Text('ERROR: No data')));
    }

    return BlocProvider(
      create: (context) =>
          ControlCubit(context.read<MqttCubit>(), tank.isHardwareBound),
      child: _ControlScreenBody(tank: tank),
    );
  }
}

class _ControlScreenBody extends StatelessWidget {
  final TankModel tank;
  const _ControlScreenBody({required this.tank});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(tank.colorValue);
    final isHardware = tank.isHardwareBound;

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
      body: BlocBuilder<MqttCubit, MqttState>(
        builder: (context, mqttState) {
          return BlocBuilder<ControlCubit, ControlState>(
            builder: (context, controlState) {
              final isConnected = mqttState is MqttDataState;
              final localOverride = isConnected && mqttState.localOverride;

              final sysActive = isHardware && isConnected
                  ? mqttState.systemActive
                  : controlState.systemPower;
              final pumpActive = isHardware && isConnected
                  ? mqttState.pumpStatus
                  : controlState.pumpState;

              final isLocked = isHardware && localOverride;
              final isDisconnected = isHardware && !isConnected;
              final isDisabled =
                  isLocked ||
                  isDisconnected ||
                  !sysActive ||
                  controlState.isAutoMode;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isHardware)
                      const InfoBanner(
                        title: 'VIRTUAL MODE',
                        sub: 'Changes are simulated locally.',
                        color: Colors.purpleAccent,
                      ),
                    if (isLocked)
                      const InfoBanner(
                        title: 'HARDWARE LOCK',
                        sub: 'Physical override active on ESP32.',
                        color: Colors.redAccent,
                      ),
                    if (isDisconnected)
                      const InfoBanner(
                        title: 'OFFLINE',
                        sub: 'Connecting to MQTT Broker...',
                        color: Colors.orangeAccent,
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

                    ModeSelector(
                      activeColor: primaryColor,
                      isAuto: controlState.isAutoMode,
                    ),
                    const SizedBox(height: 30),

                    ControlToggle(
                      label: 'Main System Unit',
                      icon: Icons.power_rounded,
                      value: sysActive,
                      activeColor: primaryColor,
                      isDisabled: isLocked || isDisconnected,
                      onChanged: (val) {
                        if (isHardware) {
                          context.read<MqttCubit>().sendCommand(
                            'system_status',
                            val,
                          );
                        } else {
                          context.read<ControlCubit>().toggleSystem(val);
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
                      value: pumpActive,
                      activeColor: primaryColor,
                      isDisabled: isDisabled,
                      onChanged: (val) {
                        if (isHardware) {
                          context.read<MqttCubit>().sendCommand(
                            'pump_command',
                            val,
                          );
                        } else {
                          context.read<ControlCubit>().togglePump(val);
                        }
                      },
                    ),

                    ControlToggle(
                      label: 'Solenoid Valve',
                      icon: Icons.water_drop_outlined,
                      value: controlState.valveState,
                      activeColor: primaryColor,
                      isDisabled: isDisabled,
                      onChanged: (val) =>
                          context.read<ControlCubit>().toggleValve(val),
                    ),

                    const Spacer(),

                    ActionButton(
                      text: 'EMERGENCY SHUTDOWN',
                      onPressed: (isLocked || isDisconnected)
                          ? null
                          : () {
                              if (isHardware) {
                                context.read<MqttCubit>().sendCommand(
                                  'pump_command',
                                  false,
                                );
                                context.read<MqttCubit>().sendCommand(
                                  'system_status',
                                  false,
                                );
                              } else {
                                context
                                    .read<ControlCubit>()
                                    .emergencyShutdown();
                              }
                            },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
