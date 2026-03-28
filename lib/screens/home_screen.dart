import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/providers/connectivity_provider.dart';
import 'package:mobile_development_iot/providers/mqtt_provider.dart';
import 'package:mobile_development_iot/repositories/tank_repository.dart';
import 'package:mobile_development_iot/widgets/main_wrapper.dart';
import 'package:mobile_development_iot/widgets/shake_simulation_wrapper.dart';
import 'package:mobile_development_iot/widgets/tech_grid.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ITankRepository _tankRepository = SecureTankRepository();
  List<TankModel> _tanks = [];
  bool _isLoading = true;
  final Color primaryColor = const Color(0xFF38BDF8);

  @override
  void initState() {
    super.initState();
    _loadTanks();
  }

  Future<void> _loadTanks() async {
    final tanks = await _tankRepository.getTanks();
    setState(() {
      _tanks = tanks;
      _isLoading = false;
    });
  }

  Future<void> _addNewTank() async {
    final titleController = TextEditingController();
    final capacityController = TextEditingController();
    int selectedColor = 0xFF38BDF8;
    final formKey = GlobalKey<FormState>();

    final bool hasHardwareNode = _tanks.any((t) => t.isHardwareBound);
    bool bindToHardware = !hasHardwareNode;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text(
            'REGISTER NEW NODE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
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
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [0xFF10B981, 0xFFFACC15, 0xFFA855F7, 0xFFFB7185]
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = c),
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

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: bindToHardware
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.white10,
                    ),
                  ),
                  child: hasHardwareNode
                      ? const Text(
                          'HARDWARE ALREADY BOUND.'
                          'This will be created as a Virtual Simulated Node.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            height: 1.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'BIND TO ESP32-S3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Switch(
                              value: bindToHardware,
                              activeThumbColor: Colors.green,
                              onChanged: (val) =>
                                  setDialogState(() => bindToHardware = val),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final newTank = TankModel(
                  id: DateTime.now().toString(),
                  title: titleController.text.trim(),
                  capacity: double.tryParse(capacityController.text) ?? 100,
                  currentLevel: 0.4,
                  colorValue: selectedColor,
                  isHardwareBound: bindToHardware,
                );

                await _tankRepository.addTank(newTank);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadTanks();
              },
              child: const Text(
                'INSTALL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTank(String id) async {
    await _tankRepository.deleteTank(id);
    _loadTanks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NODE DECOMMISSIONED'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: ShakeSimulationWrapper(
        tanks: _tanks,
        child: Stack(
          children: [
            const TechGrid(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(isOnline),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _tanks.isEmpty
                        ? _buildEmptyState()
                        : _buildTankGrid(),
                  ),
                  MainWrapper(
                    primaryColor: isOnline ? primaryColor : Colors.grey,
                    onAddPressed: isOnline ? _addNewTank : null,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isOnline) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOnline ? Icons.radar_rounded : Icons.wifi_off_rounded,
                color: isOnline ? Colors.white24 : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'SMART FLUID MANAGEMENT',
                style: TextStyle(
                  color: isOnline
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.redAccent,
                  letterSpacing: 4,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isOnline ? 'DISPATCHER CENTER' : 'OFFLINE MODE : LOCAL DATA ONLY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isOnline
                  ? Colors.white38
                  : Colors.redAccent.withValues(alpha: 0.5),
              letterSpacing: 8,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
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
            Icons.nearby_error_rounded,
            size: 60,
            color: primaryColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO NODES DETECTED',
            style: TextStyle(
              color: Colors.white24,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'PLEASE INITIALIZE NEW TANK NODE',
            style: TextStyle(color: Colors.white10, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTankGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.4,
      ),
      itemCount: _tanks.length,
      itemBuilder: (context, index) {
        final tank = _tanks[index];
        final tankColor = Color(tank.colorValue);

        return _buildTankCard(tank, tankColor);
      },
    );
  }

  Widget _buildTankCard(TankModel tank, Color color) {
    final mqtt = context.watch<MqttProvider>();
    final isHardware = tank.isHardwareBound;

    return Stack(
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, '/details', arguments: tank),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isHardware ? Icons.memory : Icons.hub_outlined,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isHardware
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isHardware ? 'ESP32' : 'VIRTUAL',
                        style: TextStyle(
                          color: isHardware ? Colors.green : Colors.white38,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tank.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(tank.currentLevel * 100).toInt()}% LOADED',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (isHardware && mqtt.isConnected)
                          Text(
                            '${mqtt.temp.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.close, color: color, size: 18),
            onPressed: () => _deleteTank(tank.id),
          ),
        ),
      ],
    );
  }
}
