import 'package:flutter/material.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/repositories/tank_repository.dart';
import 'package:mobile_development_iot/widgets/main_wrapper.dart';
import 'package:mobile_development_iot/widgets/tech_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ITankRepository _tankRepository = SharedPrefsTankRepository();
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

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text(
            'REGISTER NEW NODE',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'NODE NAME',
                    labelStyle: TextStyle(color: Colors.white38),
                    errorStyle: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
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
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () async {
                final newTank = TankModel(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  capacity: double.tryParse(capacityController.text) ?? 100,
                  currentLevel: 0.4,
                  colorValue: selectedColor,
                );
                await _tankRepository.addTank(newTank);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadTanks();
              },
              child: const Text('INSTALL'),
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
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          const TechGrid(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _tanks.isEmpty
                      ? _buildEmptyState()
                      : _buildTankGrid(),
                ),

                MainWrapper(
                  primaryColor: primaryColor,
                  onAddPressed: _addNewTank,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.radar_rounded, color: Colors.white24, size: 20),
              const SizedBox(width: 10),
              Text(
                'SMART FLUID MANAGEMENT',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 4,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          const Text(
            'DISPATCHER CENTER',
            style: TextStyle(
              color: Colors.white38,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Icon(Icons.hub_outlined, color: color, size: 20)],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATION NAME:',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    Text(
                      '${(tank.currentLevel * 100).toInt()}% LOADED',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
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
