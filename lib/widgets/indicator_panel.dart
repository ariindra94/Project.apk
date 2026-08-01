import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class IndicatorPanel extends StatelessWidget {
  final DashboardData data;

  const IndicatorPanel({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildItem(Icons.light_mode, "HIGH BEAM", data.highbeam, const Color(0xFF29B6F6)),
        const SizedBox(height: 6),
        _buildNeutralItem("N", "NEUTRAL", data.neutral),
        const SizedBox(height: 6),
        _buildItem(Icons.warning_amber_rounded, "ABS", data.abs, Colors.amberAccent),
        const SizedBox(height: 6),
        _buildItem(Icons.oil_barrel, "OIL", data.oil, Colors.redAccent),
        const SizedBox(height: 6),
        _buildItem(Icons.build_circle_outlined, "CHECK ENG", data.engine, Colors.amberAccent),
      ],
    );
  }

  Widget _buildItem(IconData icon, String label, bool isActive, Color activeColor) {
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
            letterSpacing: 0.5,
          ),
        )
      ],
    );
  }

  Widget _buildNeutralItem(String text, String label, bool isActive) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.greenAccent : Colors.white24,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white70 : Colors.white24,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        )
      ],
    );
  }
}
