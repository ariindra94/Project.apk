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
      backgroundColor: Colors.black,
      body: StreamBuilder<DashboardData>(
        stream: _serialService.dataStream,
        initialData: DashboardData.initial(),
        builder: (context, snapshot) {
          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_back, color: data.leftIndicator ? Colors.green : Colors.white12, size: 28),
                          const SizedBox(width: 8),
                          _buildTopInfo("VOLT", "${data.volt} V", Colors.greenAccent),
                          const SizedBox(width: 12),
                          _buildTopInfo("TEMP", "${data.temp} °C", Colors.blueAccent),
                        ],
                      ),
                      IndicatorPanel(data: data),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: RpmGauge(rpm: data.rpm, speed: data.speed, gear: data.gear),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildTopInfo("FUEL", "${data.fuel} L", Colors.amber),
                          const SizedBox(width: 12),
                          _buildTopInfo("ODO", "${data.odo} km", Colors.cyanAccent),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: data.rightIndicator ? Colors.green : Colors.white12, size: 28),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("TRIP A", style: TextStyle(color: Colors.grey, fontSize: 10)),
                              Text("${data.trip} km", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(width: 15),
                          FuelGauge(fuelPercent: data.fuel),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
