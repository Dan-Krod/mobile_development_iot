import 'package:flutter/material.dart';
import 'package:mobile_development_iot/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

class ConnectivityOverlay extends StatelessWidget {
  final Widget child;

  const ConnectivityOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return Stack(
      children: [
        child,

        if (!isOnline)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.redAccent,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'OFFLINE MODE: SYSTEM DISCONNECTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
