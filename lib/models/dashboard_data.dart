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
  final String clock;

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
    required this.clock,
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
      clock: json['clock'] ?? "10:25:30",
    );
  }

  factory DashboardData.initial() {
    return DashboardData(
      speed: 135,
      rpm: 8500,
      gear: 6,
      temp: 28,
      fuel: 7.6,
      volt: 12.8,
      trip: 235.6,
      odo: 12035,
      leftIndicator: true,
      rightIndicator: true,
      highbeam: true,
      neutral: true,
      abs: true,
      oil: true,
      engine: true,
      clock: "10:25:30",
    );
  }
}
