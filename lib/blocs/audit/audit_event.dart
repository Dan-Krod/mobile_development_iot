abstract class AuditEvent {}

class FetchLogsEvent extends AuditEvent {}

class AddLogEvent extends AuditEvent {
  final String action;
  AddLogEvent(this.action);
}
