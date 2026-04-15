import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class ShakeSimulationWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRawShake;

  const ShakeSimulationWrapper({
    required this.child,
    this.onRawShake,
    super.key,
  });

  @override
  State<ShakeSimulationWrapper> createState() => _ShakeSimulationWrapperState();
}

class _ShakeSimulationWrapperState extends State<ShakeSimulationWrapper> {
  late ShakeDetector detector;

  @override
  void initState() {
    super.initState();
    developer.log('[SYSTEM] ShakeDetector Initializing (Smart Mode)...');

    detector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.5,
      shakeSlopTimeMS: 200,
      onPhoneShake: (_) {
        if (!mounted) return;

        final isCurrentScreen = ModalRoute.of(context)?.isCurrent ?? false;

        if (isCurrentScreen) {
          developer.log('\n[SENSOR] SHAKE DETECTED! Active screen responding.');
          widget.onRawShake?.call();
        } else {
          developer.log('\n[SENSOR] Ignored: Screen is in background.');
        }
      },
    );
  }

  @override
  void dispose() {
    developer.log('[SYSTEM] ShakeDetector Disposed');
    detector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
