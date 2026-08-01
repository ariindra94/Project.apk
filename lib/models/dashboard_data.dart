class DashboardData {
  final int speed;
  final int rpm;
  final int gear;
  final int temp;
  final double fuel;
  final double volt;
  final double trip;
  final int odo;
  final bool leftIndicator;
  final bool rightIndicator;
  final bool highbeam;
  final bool neutral;
  final bool abs;
  final bool oil;
  final bool engine;

  DashboardData({
    required this.speed,
    required this.rpm,
    required this.gear,
    required this.temp,
    required this.fuel,
    required this.volt,
    required this.trip,
    required this.odo,
    required this.leftIndicator,
    required this.rightIndicator,
    required this.highbeam,
    required this.neutral,
    required this.abs,
    required this.oil,
    required this.engine,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      speed: json['speed'] ?? 0,
      rpm: json['rpm'] ?? 0,
      gear: json['gear'] ?? 0,
      temp: json['temp'] ?? 0,
      fuel: (json['fuel'] as num?)?.toDouble() ?? 0.0,
      volt: (json['volt'] as num?)?.toDouble() ?? 0.0,
      trip: (json['trip'] as num?)?.toDouble() ?? 0.0,
      odo: json['odo'] ?? 0,
      leftIndicator: json['left'] ?? false,
      rightIndicator: json['right'] ?? false,
      highbeam: json['highbeam'] ?? false,
      neutral: json['neutral'] ?? false,
      abs: json['abs'] ?? false,
      oil: json['oil'] ?? false,
      engine: json['engine'] ?? false,
    );
  }

  factory DashboardData.initial() {
    return DashboardData(
      speed: 0, rpm: 0, gear: 0, temp: 0, fuel: 0.0, volt: 0.0,
      trip: 0.0, odo: 0, leftIndicator: false, rightIndicator: false,
      highbeam: false, neutral: true, abs: false, oil: false, engine: false,
    );
  }
}
