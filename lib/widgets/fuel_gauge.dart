import 'package:flutter/material.dart';

class FuelGauge extends StatelessWidget {
  final double fuelPercent; // Skala 0.0 - 100.0 %

  const FuelGauge({Key? key, required this.fuelPercent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalBars = 6;
    int activeBars = ((fuelPercent / 100) * totalBars).round();

    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("F", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            Icon(Icons.local_gas_station, color: Colors.white30, size: 14),
            SizedBox(height: 30),
            Text("E", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1.5),
            borderRadius: BorderRadius.circular(4),
            color: Colors.black45,
          ),
          child: Column(
            children: List.generate(totalBars, (index) {
              int barIndex = totalBars - 1 - index;
              bool isActive = barIndex < activeBars;
              Color barColor = barIndex == 0 ? Colors.redAccent : Colors.greenAccent;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 1.5),
                width: 22,
                height: 10,
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
}
