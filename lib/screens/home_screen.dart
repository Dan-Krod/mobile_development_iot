import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/connectivity_cubit.dart';
import 'package:mobile_development_iot/cubits/tank_cubit.dart';
import 'package:mobile_development_iot/models/tank_model.dart';
import 'package:mobile_development_iot/widgets/dialogs/add_tank_dialog.dart';
import 'package:mobile_development_iot/widgets/hud/home_header.dart';
import 'package:mobile_development_iot/widgets/hud/tech_grid.dart';
import 'package:mobile_development_iot/widgets/layout/main_wrapper.dart';
import 'package:mobile_development_iot/widgets/layout/shake_simulation_wrapper.dart';
import 'package:mobile_development_iot/widgets/tank/tank_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddDialog(BuildContext context, List<TankModel> tanks) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          AddTankDialog(hasHardwareNode: tanks.any((t) => t.isHardwareBound)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline =
        context.watch<ConnectivityCubit>().state is ConnectivityOnline;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: BlocListener<TankCubit, TankState>(
        listener: _handleActions,
        child: BlocBuilder<TankCubit, TankState>(
          buildWhen: (prev, curr) =>
              curr is! TankAddSuccess &&
              curr is! TankDeleteSuccess &&
              curr is! TankActionError,
          builder: (context, state) {
            final tanks = state is TankLoaded ? state.tanks : <TankModel>[];
            return ShakeSimulationWrapper(
              tanks: tanks,
              child: Stack(
                children: [
                  const TechGrid(),
                  SafeArea(
                    child: Column(
                      children: [
                        HomeHeader(isOnline: isOnline),
                        Expanded(
                          child: state is TankLoading
                              ? const Center(child: CircularProgressIndicator())
                              : tanks.isEmpty
                              ? _buildEmpty()
                              : _buildGrid(tanks),
                        ),
                        MainWrapper(
                          primaryColor: isOnline
                              ? const Color(0xFF38BDF8)
                              : Colors.grey,
                          onAddPressed: isOnline
                              ? () => _showAddDialog(context, tanks)
                              : null,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleActions(BuildContext context, TankState state) {
    if (state is TankAddSuccess ||
        state is TankDeleteSuccess ||
        state is TankActionError) {
      final isError = state is TankActionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isError ? (state).message : (state as dynamic).message as String,
          ),
          backgroundColor: state is TankAddSuccess
              ? Colors.green
              : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildGrid(List<TankModel> tanks) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.4,
      ),
      itemCount: tanks.length,
      itemBuilder: (context, index) => TankCard(tank: tanks[index]),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.nearby_error_rounded, size: 60, color: Colors.white10),
          SizedBox(height: 16),
          Text(
            'NO NODES DETECTED',
            style: TextStyle(
              color: Colors.white24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            'PLEASE INITIALIZE NEW TANK NODE',
            style: TextStyle(color: Colors.white10, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
