import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/mqtt/mqtt_bloc.dart';
import 'package:mobile_development_iot/blocs/secret_mode/secret_mode_bloc.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/widgets/dialogs/unsupported_os_dialog.dart';
import 'package:mobile_development_iot/widgets/tank/fluid_tank_observation.dart';
import 'package:mobile_development_iot/widgets/tank/status_badge.dart';
import 'package:mobile_development_iot/widgets/tank/tank_sensor_row.dart';
import 'package:mobile_development_iot/widgets/tank/tank_ui_components.dart';
import 'package:mobile_development_iot/widgets/tank/tank_wrapper.dart';

class TankDetailsScreen extends StatelessWidget {
  const TankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tank = ModalRoute.of(context)!.settings.arguments as TankModel;
    final tankColor = Color(tank.colorValue);
    final isHardware = tank.isHardwareBound;

    return BlocProvider(
      create: (context) {
        if (isHardware) {
          final mqtt = context.read<MqttBloc>();
          if (mqtt.state is MqttInitial || mqtt.state is MqttDisconnected) {
            mqtt.add(ConnectMqttEvent('10.217.121.222'));
          }
        }
        return SecretModeBloc(
          context.read<IAuthRepository>(),
          context.read<ApiClient>(),
        );
      },
      child: BlocConsumer<SecretModeBloc, SecretModeState>(
        listener: (context, secretState) {
          if (secretState is SecretModeUnsupportedOS) {
            UnsupportedOsDialog.show(context);
          } else if (secretState is SecretModeToggled) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            if (secretState.isSecretModeActive) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚡ EMERGENCY OVERRIDE ENGAGED'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ PROTOCOL DISENGAGED: FLASHLIGHT OFF'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        builder: (context, secretState) {
          final isSecret = secretState.isSecretModeActive;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: isSecret
                    ? [
                        const Color.fromARGB(255, 84, 9, 9),
                        const Color.fromARGB(255, 31, 3, 3),
                      ]
                    : [const Color(0xFF020617), const Color(0xFF020617)],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: GestureDetector(
                  onTap: () => context.read<SecretModeBloc>().add(
                    RegisterSecretTapEvent(),
                  ),
                  child: Column(
                    children: [
                      Text(
                        tank.title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      BlocBuilder<MqttBloc, MqttState>(
                        builder: (context, mqttState) {
                          return StatusBadge(
                            isHardware: isHardware,
                            state: mqttState,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: Column(
                children: [
                  if (isSecret) const EmergencyOverrideBanner(),
                  Expanded(
                    flex: 7,
                    child: ObservationBay(
                      primaryColor: tankColor,
                      onTankTap: () {},
                    ),
                  ),
                  GlowingDivider(color: tankColor),
                  BlocBuilder<MqttBloc, MqttState>(
                    builder: (context, mqttState) {
                      return TankSensorRow(
                        color: tankColor,
                        isHardware: isHardware,
                        state: mqttState,
                      );
                    },
                  ),
                  TankWrapper(tank: tank),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
