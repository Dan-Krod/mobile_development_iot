import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/alarm_model.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/alarm_repository.dart';
import 'package:mobile_development_iot/widgets/alarm_item.dart';
import 'package:mobile_development_iot/widgets/tech_grid.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  final IAlarmRepository _repository = SharedPrefsAlarmRepository();
  List<AlarmModel> _alarms = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final tank = ModalRoute.of(context)!.settings.arguments as TankModel;
    final data = await _repository.getAlarmsByTank(tank.id);
    setState(() {
      _alarms = data;
      _isLoading = false;
    });
  }

  Future<void> _clearLogs(String tankId) async {
    await _repository.clearAlarms(tankId);
    setState(() => _alarms = []);
  }

  Future<void> _simulateAlarm(String tankId) async {
    final now = DateTime.now();
    final newAlarm = AlarmModel(
      id: now.millisecondsSinceEpoch.toString(),
      tankId: tankId,
      message: 'System alert: unusual pressure detected!',
      time: '${now.hour}:${now.minute}:${now.second}',
      isCritical: now.second % 2 == 0,
    );

    await _repository.addAlarm(newAlarm);
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final tank = ModalRoute.of(context)!.settings.arguments as TankModel;
    final primaryColor = Color(tank.colorValue);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text('${tank.title} LOGS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded, color: Colors.white38),
            onPressed: () => _simulateAlarm(tank.id),
          ),
        ],
      ),
      body: Stack(
        children: [
          const TechGrid(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                Expanded(
                  child: _alarms.isEmpty
                      ? _buildEmptyState()
                      : _buildAlarmList(),
                ),

                if (_alarms.isNotEmpty)
                  _buildClearButton(tank.id, primaryColor),
              ],
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

  Widget _buildAlarmList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: _alarms.length,
      itemBuilder: (context, index) {
        final alarm = _alarms[index];
        return AlarmItem(
          time: alarm.time,
          message: alarm.message,
          isCritical: alarm.isCritical,
        );
      },
    );
  }

  Widget _buildClearButton(String tankId, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextButton.icon(
        onPressed: () => _clearLogs(tankId),
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
