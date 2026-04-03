import 'package:flutter/material.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SYSTEM AUDIT LOGS',
          style: TextStyle(letterSpacing: 2, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: FutureBuilder(
        future: apiClient.getLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.redAccent,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'SERVER OFFLINE\nLogs unavailable',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            final List<dynamic> logs = snapshot.data!.data as List<dynamic>;

            if (logs.isEmpty) {
              return const Center(
                child: Text(
                  'NO LOGS FOUND',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final log = logs[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.security, color: Colors.blueAccent),
                  title: Text(
                    (log['action'] as String?) ?? 'Unknown Action',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Operator: ${log['userEmail']}\nTime: ${log['timestamp']}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
