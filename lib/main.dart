import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0D12),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ============================================================================
// MODEL DATA
// ============================================================================
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

// ============================================================================
// SERVICE USB SERIAL
// ============================================================================
class UsbSerialService {
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<DashboardData> _controller = StreamController<DashboardData>.broadcast();

  Stream<DashboardData> get dataStream => _controller.stream;

  Future<void> startListening() async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      if (devices.isEmpty) return;

      _port = await devices.first.create();
      bool? openResult = await _port?.open();
      if (openResult != true) return;

      await _port?.setDTR(true);
      await _port?.setRTS(true);
      await _port?.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

      String buffer = "";
      _subscription = _port?.inputStream?.listen((Uint8List data) {
        buffer += String.fromCharCodes(data);
        if (buffer.contains('\n')) {
          List<String> lines = buffer.split('\n');
          for (int i = 0; i < lines.length - 1; i++) {
            String line = lines[i].trim();
            if (line.isNotEmpty) {
              try {
                Map<String, dynamic> parsedJson = jsonDecode(line);
                _controller.add(DashboardData.fromJson(parsedJson));
              } catch (_) {}
            }
          }
          buffer = lines.last;
        }
      });
    } catch (_) {}
  }

  void stopListening() {
    _subscription?.cancel();
    _port?.close();
    _controller.close();
  }
}

// ============================================================================
// MAIN DASHBOARD SCREEN
// ============================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UsbSerialService _serialService = UsbSerialService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _serialService.startListening();
  }

  @override
  void dispose() {
    _serialService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D12),
      body: StreamBuilder<DashboardData>(
        stream: _serialService.dataStream,
        initialData: DashboardData.initial(),
        builder: (context, snapshot) {
          final data = snapshot.data!;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Column(
                children: [
                  // --- HEADER ATAS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildHeaderItem("${data.volt} v", "VOLT", Icons.battery_charging_full, Colors.greenAccent),
                          const SizedBox(width: 16),
                          _buildHeaderItem("${data.temp} °C", "TEMP", Icons.thermostat, Colors.blueAccent),
                        ],
                      ),
                      Text(
                        data.clock,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderItem("${data.fuel} L", "FUEL", Icons.local_gas_station, Colors.amberAccent),
                          const SizedBox(width: 16),
                          _buildHeaderItem("${data.odo}", "ODO (km)", null, Colors.cyanAccent),
                        ],
                      ),
                    ],
                  ),

                  // --- BODY UTAMA ---
                  Expanded(
                    child: Row(
                      children: [
                        // KIRI: SEIN KIRI & PANEL INDIKATOR
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: data.leftIndicator ? Colors.greenAccent : Colors.white12,
                                size: 26,
                              ),
                              const Spacer(),
                              _buildIndicatorPanel(data),
                              const Spacer(),
                            ],
                          ),
                        ),

                        // TENGAH: RPM & SPEEDOMETER GAUGE
                        Expanded(
                          flex: 5,
                          child: _buildRpmGauge(data.rpm, data.speed, data.gear),
                        ),

                        // KANAN: SEIN KANAN, TANGKI BENSIN, TRIP A
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                color: data.rightIndicator ? Colors.greenAccent : Colors.white12,
                                size: 26,
                              ),
                              const Spacer(),
                              _buildFuelGauge((data.fuel / 10.0) * 100),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("TRIP A", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text("${data.trip} km", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- FOOTER BAWAH (RIDING MODES) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeItem("RACE", true),
                      _buildModeItem("SPORT", false),
                      _buildModeItem("STREET", false),
                      _buildModeItem("RAIN", false),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // WIDGET HELPER
  Widget _buildHeaderItem(String val, String label, IconData? icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            if (icon != null) ...[
              const SizedBox(width: 3),
              Icon(icon, color: color, size: 12),
            ]
          ],
        ),
        Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIndicatorPanel(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIndiRow(Icons.light_mode, "HIGH BEAM", data.highbeam, const Color(0xFF29B6F6)),
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: 16,
              child: Text(
                "N",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: data.neutral ? Colors.greenAccent : Colors.white24,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text("NEUTRAL", style: TextStyle(color: data.neutral ? Colors.white70 : Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        _buildIndiRow(Icons.warning_amber_rounded, "ABS", data.abs, Colors.amberAccent),
        const SizedBox(height: 6),
        _buildIndiRow(Icons.oil_barrel, "OIL", data.oil, Colors.redAccent),
        const SizedBox(height: 6),
        _buildIndiRow(Icons.build_circle_outlined, "CHECK ENG", data.engine, Colors.amberAccent),
      ],
    );
  }

  Widget _buildIndiRow(IconData icon, String label, bool isActive, Color activeColor) {
    return Row(
      children: [
        Icon(icon, color: isActive ? activeColor : Colors.white24, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white70 : Colors.white24,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Widget _buildRpmGauge(int rpm, int speed, int gear) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 12000,
          startAngle: 140,
          endAngle: 40,
          interval: 1000,
          showLabels: true,
          showTicks: true,
          minorTicksPerInterval: 4,
          axisLineStyle: const AxisLineStyle(thickness: 10, color: Colors.white10),
          onLabelCreated: (AxisLabelCreatedArgs args) {
            int val = (double.tryParse(args.text) ?? 0) ~/ 1000;
            args.text = '$val';
          },
          axisLabelStyle: const GaugeTextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          pointers: <GaugePointer>[
            RangePointer(
              value: rpm.toDouble(),
              width: 12,
              gradient: const SweepGradient(
                colors: <Color>[Colors.blueAccent, Colors.cyan, Colors.redAccent],
                stops: <double>[0.0, 0.65, 1.0],
              ),
              enableAnimation: true,
            ),
            NeedlePointer(
              value: rpm.toDouble(),
              needleColor: Colors.redAccent,
              knobStyle: const KnobStyle(color: Colors.transparent),
              needleLength: 0.85,
              needleStartWidth: 1,
              needleEndWidth: 3,
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.05,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("x1000 RPM", style: TextStyle(color: Colors.grey, fontSize: 9, fontStyle: FontStyle.italic)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$speed',
                        style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -2),
                      ),
                      const SizedBox(width: 4),
                      const Text('km/h', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
            ),
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.78,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("GEAR", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  Text(
                    gear == 0 ? 'N' : '$gear',
                    style: TextStyle(
                      color: gear == 0 ? Colors.greenAccent : const Color(0xFF29B6F6),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildFuelGauge(double fuelPercent) {
    int totalBars = 6;
    int activeBars = ((fuelPercent / 100) * totalBars).round();

    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("F", style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
            SizedBox(height: 18),
            Icon(Icons.local_gas_station, color: Colors.white30, size: 12),
            SizedBox(height: 18),
            Text("E", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1.2),
            borderRadius: BorderRadius.circular(3),
            color: Colors.black45,
          ),
          child: Column(
            children: List.generate(totalBars, (index) {
              int barIndex = totalBars - 1 - index;
              bool isActive = barIndex < activeBars;
              Color barColor = barIndex == 0 ? Colors.redAccent : Colors.greenAccent;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                width: 18,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive ? barColor : Colors.white10,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildModeItem(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.white24,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
