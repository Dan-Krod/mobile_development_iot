class UserModel {
  final String fullName;
  final String email;
  final String password;
  final String hardware;
  final String database;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.hardware,
    required this.database,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'hardware': hardware,
    'database': database,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    hardware: json['hardware'] as String? ?? 'ESP32-S3',
    database: json['database'] as String? ?? 'Shared Preferences',
  );
}
