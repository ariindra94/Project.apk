import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RpmGauge extends StatelessWidget {
  final int rpm;
  final int speed;
  final int gear;

  const RpmGauge({
    Key? key,
    required this.rpm,
    required this.speed,
    required this.gear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          axisLineStyle: const AxisLineStyle(thickness: 10, color: Colors.white10),
          labelFormat: '{value}',
          axisLabelStyle: const GaugeTextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          pointers: <GaugePointer>[
            RangePointer(
              value: rpm.toDouble(),
              width: 14,
              gradient: const SweepGradient(
                colors: <Color>[Colors.blue, Colors.cyan, Colors.red],
                stops: <double>[0.0, 0.7, 1.0],
              ),
              enableAnimation: true,
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.1,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$speed', style: const TextStyle(color: Colors.white, fontSize: 75, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const Text('km/h', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.75,
              widget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("GEAR ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    gear == 0 ? 'N' : '$gear',
                    style: TextStyle(
                      color: gear == 0 ? Colors.green : Colors.blueAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
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
}
