class TankModel {
  final String id;
  final String title;
  final double currentLevel;
  final double capacity;
  final String unit;
  final int colorValue;

  TankModel({
    required this.id,
    required this.title,
    required this.currentLevel,
    required this.capacity,
    this.unit = 'L',
    this.colorValue = 0xFF38BDF8,
  });

  TankModel copyWith({
    String? title,
    double? currentLevel,
    double? capacity,
    String? unit,
    int? colorValue,
  }) {
    return TankModel(
      id: id,
      title: title ?? this.title,
      currentLevel: currentLevel ?? this.currentLevel,
      capacity: capacity ?? this.capacity,
      unit: unit ?? this.unit,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'currentLevel': currentLevel,
    'capacity': capacity,
    'unit': unit,
    'colorValue': colorValue,
  };

  factory TankModel.fromJson(Map<String, dynamic> json) => TankModel(
    id: json['id'] as String,
    title: json['title'] as String,
    currentLevel: (json['currentLevel'] as num).toDouble(),
    capacity: (json['capacity'] as num).toDouble(),
    unit: json['unit'] as String,
    colorValue: json['colorValue'] as int? ?? 0xFF38BDF8,
  );
}
