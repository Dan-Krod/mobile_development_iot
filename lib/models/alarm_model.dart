class AlarmModel {
  final String id;
  final String tankId;
  final String message;
  final String time;
  final bool isCritical;

  AlarmModel({
    required this.id,
    required this.tankId,
    required this.message,
    required this.time,
    this.isCritical = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'tankId': tankId,
    'message': message,
    'time': time,
    'isCritical': isCritical,
  };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
    id: json['id'] as String,
    tankId: json['tankId'] as String,
    message: json['message'] as String,
    time: json['time'] as String,
    isCritical: json['isCritical'] as bool,
  );
}
