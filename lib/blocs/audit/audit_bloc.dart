import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_development_iot/blocs/audit/audit_event.dart';
import 'package:mobile_development_iot/blocs/audit/audit_state.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';

export 'audit_event.dart';
export 'audit_state.dart';

class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  AuditBloc(this._apiClient) : super(AuditLoading()) {
    on<FetchLogsEvent>(_onFetchLogs);
    on<AddLogEvent>(_onAddLog);

    add(FetchLogsEvent());
  }

  Future<void> _onFetchLogs(
    FetchLogsEvent event,
    Emitter<AuditState> emit,
  ) async {
    emit(AuditLoading());
    try {
      final response = await _apiClient.getLogs();
      if (response.statusCode == 200) {
        emit(AuditLoaded(response.data as List<dynamic>));
      } else {
        emit(AuditError('SERVER ERROR'));
      }
    } catch (e) {
      emit(AuditError('SERVER OFFLINE\nLogs unavailable'));
    }
  }

  Future<void> _onAddLog(AddLogEvent event, Emitter<AuditState> emit) async {
    try {
      final email = await _storage.read(key: 'email') ?? 'SYSTEM';
      await _apiClient.postLog(email, event.action);

      add(FetchLogsEvent());
    } catch (e) {
      debugPrint('Audit log failed: $e');
    }
  }
}
