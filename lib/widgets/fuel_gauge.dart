import 'package:flutter/material.dart';

class FuelGauge extends StatelessWidget {
  final double fuelPercent;

  const FuelGauge({Key? key, required this.fuelPercent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalBars = 6;
    int activeBars = ((fuelPercent / 100) * totalBars).round();

    return Column(
      children: [
        const Text("F", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Column(
          children: List.generate(totalBars, (index) {
            int barIndex = totalBars - 1 - index;
            bool isActive = barIndex < activeBars;
            Color barColor = barIndex == 0 ? Colors.red : Colors.greenAccent;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              width: 24,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? barColor : Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        const Text("E", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
