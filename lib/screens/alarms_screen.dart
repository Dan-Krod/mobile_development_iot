import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/alarm_cubit.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/alarm_repository.dart';
import 'package:mobile_development_iot/widgets/common/alarm_item.dart';
import 'package:mobile_development_iot/widgets/hud/tech_grid.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tank = ModalRoute.of(context)!.settings.arguments as TankModel;

    return BlocProvider(
      create: (context) =>
          AlarmCubit(context.read<IAlarmRepository>(), tank.id),
      child: _AlarmsScreenBody(tank: tank),
    );
  }
}

class _AlarmsScreenBody extends StatelessWidget {
  final TankModel tank;
  const _AlarmsScreenBody({required this.tank});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(tank.colorValue);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text('${tank.title} LOGS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded, color: Colors.white38),
            onPressed: () => context.read<AlarmCubit>().simulateAlarm(),
          ),
        ],
      ),
      body: Stack(
        children: [
          const TechGrid(),
          BlocBuilder<AlarmCubit, AlarmState>(
            builder: (context, state) {
              if (state is AlarmLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AlarmError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              } else if (state is AlarmLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: state.alarms.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              itemCount: state.alarms.length,
                              itemBuilder: (context, index) {
                                final alarm = state.alarms[index];
                                return AlarmItem(
                                  time: alarm.time,
                                  message: alarm.message,
                                  isCritical: alarm.isCritical,
                                );
                              },
                            ),
                    ),
                    if (state.alarms.isNotEmpty)
                      _buildClearButton(context, primaryColor),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            'SYSTEM OPERATIONAL',
            style: TextStyle(
              color: Colors.white24,
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const Text(
            'NO ACTIVE ALARMS DETECTED',
            style: TextStyle(color: Colors.white10, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton(BuildContext context, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextButton.icon(
        onPressed: () => context.read<AlarmCubit>().clearAlarms(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: color.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
        ),
        icon: Icon(Icons.playlist_add_check_rounded, color: color, size: 20),
        label: Text(
          'ACKNOWLEDGE ALL ENTRIES',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
