import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';

abstract class AuditState {}

class AuditLoading extends AuditState {}

class AuditLoaded extends AuditState {
  final List<dynamic> logs;
  AuditLoaded(this.logs);
}

class AuditError extends AuditState {
  final String message;
  AuditError(this.message);
}

class AuditCubit extends Cubit<AuditState> {
  final ApiClient _apiClient;

  AuditCubit(this._apiClient) : super(AuditLoading()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
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
}
