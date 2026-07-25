import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Kunci orientasi ke Landscape Imersif
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const Esp32DashApp());
}

// -----------------------------------------------------------------------------
// 1. MODEL DATA DASHBOARD
// -----------------------------------------------------------------------------
class DashboardData {
  final int speed;
  final int rpm;
  final int gear;
  final double temp;
  final double fuel;
  final double volt;
  final double trip;
  final double odo;
  final bool left;
  final bool right;
  final bool highbeam;
  final bool neutral;
  final bool abs;
  final bool oil;
  final bool engine;
  final String mode;

  DashboardData({
    this.speed = 135,
    this.rpm = 6500,
    this.gear = 6,
    this.temp = 82.0,
    this.fuel = 68.0,
    this.volt = 12.8,
    this.trip = 235.6,
    this.odo = 12035.0,
    this.left = false,
    this.right = true,
    this.highbeam = true,
    this.neutral = false,
    this.abs = true,
    this.oil = false,
    this.engine = false,
    this.mode = 'RACE',
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      speed: json['speed'] ?? 0,
      rpm: json['rpm'] ?? 0,
      gear: json['gear'] ?? 0,
      temp: (json['temp'] ?? 0).toDouble(),
      fuel: (json['fuel'] ?? 0).toDouble(),
      volt: (json['volt'] ?? 12.0).toDouble(),
      trip: (json['trip'] ?? 0).toDouble(),
      odo: (json['odo'] ?? 0).toDouble(),
      left: json['left'] ?? false,
      right: json['right'] ?? false,
      highbeam: json['highbeam'] ?? false,
      neutral: json['neutral'] ?? false,
      abs: json['abs'] ?? false,
      oil: json['oil'] ?? false,
      engine: json['engine'] ?? false,
      mode: json['mode'] ?? 'RACE',
    );
  }

  DashboardData copyWith({
    int? speed,
    int? rpm,
    int? gear,
    double? temp,
    double? fuel,
    double? volt,
    double? trip,
    double? odo,
    bool? left,
    bool? right,
    bool? highbeam,
    bool? neutral,
    bool? abs,
    bool? oil,
    bool? engine,
    String? mode,
  }) {
    return DashboardData(
      speed: speed ?? this.speed,
      rpm: rpm ?? this.rpm,
      gear: gear ?? this.gear,
      temp: temp ?? this.temp,
      fuel: fuel ?? this.fuel,
      volt: volt ?? this.volt,
      trip: trip ?? this.trip,
      odo: odo ?? this.odo,
      left: left ?? this.left,
      right: right ?? this.right,
      highbeam: highbeam ?? this.highbeam,
      neutral: neutral ?? this.neutral,
      abs: abs ?? this.abs,
      oil: oil ?? this.oil,
      engine: engine ?? this.engine,
      mode: mode ?? this.mode,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. MAIN APP & THEME CONFIGURATION
// -----------------------------------------------------------------------------
class Esp32DashApp extends StatelessWidget {
  const Esp32DashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22D3EE),
          surface: Color(0xFF0F172A),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. DASHBOARD MAIN SCREEN
// -----------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  DashboardData _data = DashboardData();
  bool _isSimulating = true;
  Timer? _simTimer;
  double _simTime = 0.0;
  bool _blinkState = false;
  Timer? _blinkTimer;

  // Status USB
  String _usbStatus = "Disconnected (Demomode)";
  final List<String> _rawLogs = [];

  @override
  void initState() {
    super.initState();
    _startSimulation();
    _startBlinkTimer();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _startBlinkTimer() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      setState(() => _blinkState = !_blinkState);
    });
  }

  void _startSimulation() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isSimulating) return;

      _simTime += 0.1;
      double rpmTarget = 4000.0 + 3500.0 * (1.0 + math.sin(_simTime * 0.8));
      double newRpm = _data.rpm + (rpmTarget - _data.rpm) * 0.2;

      int gear = _data.gear;
      if (newRpm > 9500 && gear < 6) gear++;
      if (newRpm < 3500 && gear > 1) gear--;

      double ratio = [0, 15, 22, 28, 34, 40, 46][gear].toDouble();
      double newSpeed = (newRpm / 1000.0) * ratio;

      setState(() {
        _data = _data.copyWith(
          rpm: newRpm.toInt().clamp(0, 12000),
          speed: newSpeed.toInt().clamp(0, 299),
          gear: gear,
          volt: 12.6 + math.sin(_simTime * 2.0) * 0.3,
          temp: 80.0 + math.sin(_simTime * 0.1) * 5.0,
          trip: _data.trip + (newSpeed / 3600.0) * 0.1,
          odo: _data.odo + (newSpeed / 3600.0) * 0.1,
        );
      });
    });
  }

  void _toggleSimulation(bool value) {
    setState(() {
      _isSimulating = value;
      if (value) {
        _startSimulation();
      } else {
        _simTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // 1. TOP HEADER BAR
              _buildTopHeaderBar(),
              const SizedBox(height: 6),

              // 2. MAIN 3-PANEL LANDSCAPE DISPLAY
              Expanded(
                child: Row(
                  children: [
                    // LEFT PANEL: Tell-tale Indicators
                    Expanded(
                      flex: 28,
                      child: _buildPanelContainer(
                        child: _buildLeftIndicatorPanel(),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // CENTER PANEL: RPM Arc & Speedometer
                    Expanded(
                      flex: 44,
                      child: _buildCenterGaugePanel(),
                    ),
                    const SizedBox(width: 8),

                    // RIGHT PANEL: Fuel Bar & Odo
                    Expanded(
                      flex: 28,
                      child: _buildPanelContainer(
                        child: _buildRightGaugePanel(),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. BOTTOM DECORATIVE PILL
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 96,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // USB Connection Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _blinkState ? 1.0 : 0.3,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22D3EE),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _usbStatus.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF22D3EE),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Volt & Temp
          Row(
            children: [
              const Icon(Icons.battery_charging_full, size: 15, color: Color(0xFF22C55E)),
              const SizedBox(width: 4),
              Text(
                "${_data.volt.toStringAsFixed(1)}V",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.thermostat, size: 15, color: Color(0xFFF97316)),
              const SizedBox(width: 4),
              Text(
                "${_data.temp.toInt()}Â°C",
                style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),

          // Digital Clock
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
              return Text(
                timeStr,
                style: const TextStyle(color: Colors.slate300, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Monospace'),
              );
            },
          ),

          // Fuel % & Odo
          Row(
            children: [
              const Icon(Icons.local_gas_station, size: 15, color: Color(0xFF22D3EE)),
              const SizedBox(width: 4),
              Text(
                "${_data.fuel.toInt()}%",
                style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 14),
              Text(
                "ODO: ${_data.odo.toInt()} km",
                style: const TextStyle(color: Colors.slate400, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),

          // Settings Trigger
          GestureDetector(
            onTap: _showSettingsDialog,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings, size: 16, color: Colors.slate300),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LEFT INDICATOR PANEL
  // ---------------------------------------------------------------------------
  Widget _buildLeftIndicatorPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Left Turn
        _buildIndicatorBadge(
          icon: Icons.arrow_back,
          label: "LEFT TURN",
          isActive: _data.left,
          activeColor: const Color(0xFF22C55E),
          isBlinking: true,
        ),
        // Highbeam
        _buildIndicatorBadge(
          icon: Icons.highlight,
          label: "HIGH BEAM",
          isActive: _data.highbeam,
          activeColor: const Color(0xFF3B82F6),
        ),
        // Neutral
        _buildIndicatorBadge(
          customLeading: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: (_data.neutral || _data.gear == 0) ? const Color(0xFF22C55E) : const Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "N",
                style: TextStyle(
                  color: (_data.neutral || _data.gear == 0) ? Colors.black : Colors.slate500,
                  fontWeight: FontWeight.black,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          label: "NEUTRAL",
          isActive: _data.neutral || _data.gear == 0,
          activeColor: const Color(0xFF22C55E),
        ),
        // ABS & Oil Tile Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.vertical(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _data.abs ? const Color(0xFFFACC15) : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    "ABS",
                    style: TextStyle(
                      color: _data.abs ? const Color(0xFFFACC15) : Colors.slate600,
                      fontWeight: FontWeight.black,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.vertical(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _data.oil ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Icon(
                  Icons.oil_barrel,
                  size: 18,
                  color: _data.oil ? const Color(0xFFEF4444) : Colors.slate700,
                ),
              ),
            ),
          ],
        ),
        // Engine Check
        _buildIndicatorBadge(
          icon: Icons.build,
          label: "ENGINE CHECK",
          isActive: _data.engine,
          activeColor: const Color(0xFFFACC15),
        ),
      ],
    );
  }

  Widget _buildIndicatorBadge({
    IconData? icon,
    Widget? customLeading,
    required String label,
    required bool isActive,
    required Color activeColor,
    bool isBlinking = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          if (customLeading != null) customLeading,
          if (icon != null)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: (isBlinking && isActive) ? (_blinkState ? 1.0 : 0.2) : 1.0,
              child: Icon(icon, size: 20, color: isActive ? activeColor : const Color(0xFF1E293B)),
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : Colors.slate600,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CENTER GAUGE PANEL (RPM ARC + SPEEDOMETER)
  // ---------------------------------------------------------------------------
  Widget _buildCenterGaugePanel() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Custom Painter Tacho Arc
        CustomPaint(
          size: Size.infinite,
          painter: RpmGaugePainter(rpm: _data.rpm),
        ),

        // Gear & Speed Display
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text("GEAR", style: TextStyle(color: Colors.slate400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            Text(
              _data.gear == 0 || _data.neutral ? "N" : "${_data.gear}",
              style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 38, fontWeight: FontWeight.black, height: 1.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "${_data.speed}",
                  style: const TextStyle(color: Colors.white, fontSize: 62, fontWeight: FontWeight.black, fontStyle: FontStyle.italic, height: 1.0),
                ),
                const SizedBox(width: 4),
                const Text("km/h", style: TextStyle(color: Colors.slate400, fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              ],
            ),
          ],
        ),

        // Bottom Riding Modes Bar
        Positioned(
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: ["RACE", "SPORT", "STREET", "RAIN"].map((mode) {
                final isSelected = _data.mode == mode;
                return GestureDetector(
                  onTap: () => setState(() => _data = _data.copyWith(mode: mode)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF22D3EE).withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: const Color(0xFF22D3EE)) : null,
                    ),
                    child: Text(
                      mode,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF22D3EE) : Colors.slate600,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT GAUGE PANEL
  // ---------------------------------------------------------------------------
  Widget _buildRightGaugePanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Right Turn Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "RIGHT TURN",
                style: TextStyle(
                  color: _data.right ? const Color(0xFF22C55E) : Colors.slate600,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _data.right ? (_blinkState ? 1.0 : 0.2) : 0.3,
                child: Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: _data.right ? const Color(0xFF22C55E) : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),

        // Vertical Segmented Fuel Gauge
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAlignment.end,
              children: [
                const Text("FUEL LEVEL", style: TextStyle(color: Colors.slate400, fontSize: 9, fontWeight: FontWeight.bold)),
                Text(
                  "${_data.fuel.toInt()}%",
                  style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              width: 38,
              height: 110,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("F", style: TextStyle(color: Color(0xFF22D3EE), fontSize: 9, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        int segIndex = 6 - index;
                        int activeSegs = ((_data.fuel / 100.0) * 6).toInt();
                        bool isActive = segIndex <= activeSegs;
                        Color segColor = segIndex == 1
                            ? const Color(0xFFEF4444)
                            : (segIndex <= 3 ? const Color(0xFFFACC15) : const Color(0xFF22D3EE));
                        return Container(
                          height: 9,
                          decoration: BoxDecoration(
                            color: isActive ? segColor : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text("E", style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),

        // Trip & Odo Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TRIP", style: TextStyle(color: Colors.slate400, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text("${_data.trip.toStringAsFixed(1)} km", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("ODO", style: TextStyle(color: Colors.slate400, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text("${_data.odo.toInt()} km", style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SETTINGS & USB MODAL DIALOG
  // ---------------------------------------------------------------------------
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: Dialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedCornerShape(16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: Color(0xFF22D3EE),
                    labelColor: Color(0xFF22D3EE),
                    unselectedLabelColor: Colors.slate400,
                    tabs: [
                      Tab(text: "USB Serial"),
                      Tab(text: "Kontrol Manual"),
                      Tab(text: "Kode ESP32"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: USB Serial
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Status USB: $_usbStatus", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() => _usbStatus = "Terhubung (USB OTG)");
                                    },
                                    child: const Text("Scan USB"),
                                  )
                                ],
                              ),
                              SwitchListTile(
                                title: const Text("Mode Simulasi Demo"),
                                value: _isSimulating,
                                onChanged: _toggleSimulation,
                              ),
                              const SizedBox(height: 10),
                              const Text("Log Serial JSON:"),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.black,
                                  child: const SingleChildScrollView(
                                    child: Text(
                                      "> {\"speed\":135,\"rpm\":6500,\"gear\":6,\"temp\":82,\"fuel\":68}\n> {\"speed\":136,\"rpm\":6600,\"gear\":6,\"temp\":82,\"fuel\":68}",
                                      style: TextStyle(color: Color(0xFF22C55E), fontFamily: 'Monospace', fontSize: 11),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // Tab 2: Manual Control
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            children: [
                              Text("Kecepatan: ${_data.speed} km/h"),
                              Slider(
                                value: _data.speed.toDouble(),
                                min: 0,
                                max: 299,
                                onChanged: (v) => setState(() => _data = _data.copyWith(speed: v.toInt())),
                              ),
                              Text("RPM: ${_data.rpm}"),
                              Slider(
                                value: _data.rpm.toDouble(),
                                min: 0,
                                max: 12000,
                                onChanged: (v) => setState(() => _data = _data.copyWith(rpm: v.toInt())),
                              ),
                              Text("Gigi: ${_data.gear}"),
                              Slider(
                                value: _data.gear.toDouble(),
                                min: 0,
                                max: 6,
                                divisions: 6,
                                onChanged: (v) => setState(() => _data = _data.copyWith(gear: v.toInt())),
                              ),
                            ],
                          ),
                        ),

                        // Tab 3: ESP32 Code
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Program Arduino / ESP32 JSON:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: const Text("Salin"),
                                    onPressed: () {
                                      Clipboard.setData(const ClipboardData(text: "// Program ESP32 Serial JSON\nvoid setup() { Serial.begin(115200); }"));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kode berhasil disalin!")));
                                    },
                                  )
                                ],
                              ),
                              const Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    "#include <Arduino.h>\n#include <ArduinoJson.h>\n\nvoid setup() {\n  Serial.begin(115200);\n}\n\nvoid loop() {\n  StaticJsonDocument<256> doc;\n  doc[\"speed\"] = 135;\n  doc[\"rpm\"] = 6500;\n  doc[\"gear\"] = 6;\n  doc[\"temp\"] = 82;\n  doc[\"fuel\"] = 68;\n  serializeJson(doc, Serial);\n  Serial.println();\n  delay(100);\n}",
                                    style: TextStyle(color: Color(0xFF22D3EE), fontFamily: 'Monospace', fontSize: 12),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 4. CUSTOM PAINTER: TACHOMETER ARC GAUGE
// -----------------------------------------------------------------------------
class RpmGaugePainter extends CustomPainter {
  final int rpm;
  RpmGaugePainter({required this.rpm});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final radius = math.min(size.width, size.height) * 0.43;

    const startAngle = 145.0 * (math.pi / 180.0);
    const sweepAngle = 250.0 * (math.pi / 180.0);

    // Track Outer Arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active RPM Arc
    double rpmFraction = (rpm.clamp(0, 12000) / 12000.0);
    if (rpmFraction > 0) {
      final activePaint = Paint()
        ..shader = const SweepGradient(
          colors: [Color(0xFF22D3EE), Color(0xFF22D3EE), Color(0xFFEF4444)],
          stops: [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * rpmFraction,
        false,
        activePaint,
      );
    }

    // Ticks & Labels 0 - 12
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 12; i++) {
      double tickFraction = i / 12.0;
      double angle = startAngle + (tickFraction * sweepAngle);

      double outerX = center.dx + math.cos(angle) * (radius + 14);
      double outerY = center.dy + math.sin(angle) * (radius + 14);

      double innerX = center.dx + math.cos(angle) * (radius - 20);
      double innerY = center.dy + math.sin(angle) * (radius - 20);

      bool isRedline = i >= 9;
      final tickPaint = Paint()
        ..color = isRedline ? const Color(0xFFEF4444) : Colors.slate600
        ..strokeWidth = (i % 2 == 0) ? 4 : 2;

      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);

      if (i % 2 == 0) {
        double textX = center.dx + math.cos(angle) * (radius - 38);
        double textY = center.dy + math.sin(angle) * (radius - 38);

        textPainter.text = TextSpan(
          text: "$i",
          style: TextStyle(
            color: isRedline ? const Color(0xFFEF4444) : Colors.slate400,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RpmGaugePainter oldDelegate) => oldDelegate.rpm != rpm;
}
