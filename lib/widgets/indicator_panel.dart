import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class IndicatorPanel extends StatelessWidget {
  final DashboardData data;

  const IndicatorPanel({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem(Icons.highlight, "HIGH BEAM", data.highbeam, Colors.blue),
        _buildItem(Icons.exposure_zero, "NEUTRAL", data.neutral, Colors.green),
        _buildItem(Icons.warning_amber_rounded, "ABS", data.abs, Colors.amber),
        _buildItem(Icons.oil_barrel, "OIL", data.oil, Colors.red),
        _buildItem(Icons.build_circle, "CHECK ENG", data.engine, Colors.amber),
      ],
    );
  }

  Widget _buildItem(IconData icon, String label, bool isActive, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: isActive ? activeColor : Colors.white24, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isActive ? activeColor : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
