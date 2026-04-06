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
