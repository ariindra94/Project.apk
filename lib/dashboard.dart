import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/dashboard_data.dart';
import 'services/usb_serial.dart';
import 'widgets/rpm_gauge.dart';
import 'widgets/indicator_panel.dart';
import 'widgets/fuel_gauge.dart';

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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // --- HEADER ATAS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildHeaderItem("${data.volt} v", "VOLT", Icons.battery_charging_full, Colors.greenAccent),
                          const SizedBox(width: 15),
                          _buildHeaderItem("${data.temp} °C", "TEMP", Icons.thermostat, Colors.blueAccent),
                        ],
                      ),
                      Text(
                        data.clock,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderItem("${data.fuel} L", "FUEL", Icons.local_gas_station, Colors.amberAccent),
                          const SizedBox(width: 15),
                          _buildHeaderItem("${data.odo}", "ODO (km)", null, Colors.cyanAccent),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // --- BODY UTAMA ---
                  Expanded(
                    child: Row(
                      children: [
                        // Kiri
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: data.leftIndicator ? Colors.greenAccent : Colors.white12,
                                size: 24,
                              ),
                              const Spacer(),
                              IndicatorPanel(data: data),
                              const Spacer(),
                            ],
                          ),
                        ),

                        // Tengah (Gauge)
                        Expanded(
                          flex: 5,
                          child: RpmGauge(
                            rpm: data.rpm,
                            speed: data.speed,
                            gear: data.gear,
                          ),
                        ),

                        // Kanan
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                color: data.rightIndicator ? Colors.greenAccent : Colors.white12,
                                size: 24,
                              ),
                              const Spacer(),
                              FuelGauge(fuelPercent: (data.fuel / 10.0) * 100),
                              const SizedBox(height: 10),
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

                  // --- FOOTER BAWAH ---
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

  Widget _buildHeaderItem(String val, String label, IconData? icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 12),
            ]
          ],
        ),
        Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildModeItem(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.white24,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
