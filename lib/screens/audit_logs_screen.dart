import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/cubits/audit_cubit.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuditCubit(context.read<ApiClient>()),
      child: const _AuditLogsScreenBody(),
    );
  }
}

class _AuditLogsScreenBody extends StatelessWidget {
  const _AuditLogsScreenBody();

  @override
  Widget build(BuildContext context) {
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
      body: BlocBuilder<AuditCubit, AuditState>(
        builder: (context, state) {
          if (state is AuditLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (state is AuditError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.redAccent,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            );
          }

          if (state is AuditLoaded) {
            if (state.logs.isEmpty) {
              return const Center(
                child: Text(
                  'NO LOGS FOUND',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.logs.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final log = state.logs[index];
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
