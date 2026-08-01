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
          minorTicksPerInterval: 4,
          axisLineStyle: const AxisLineStyle(
            thickness: 12,
            color: Colors.white10,
          ),
          labelFormat: '{value}',
          onLabelCreated: (AxisLabelCreatedArgs args) {
            int val = int.parse(args.text) ~/ 1000;
            args.text = '$val';
          },
          axisLabelStyle: const GaugeTextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: rpm.toDouble(),
              width: 14,
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
                  const Text(
                    "x1000 RPM",
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$speed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 65,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'km/h',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
                  const Text("GEAR", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    gear == 0 ? 'N' : '$gear',
                    style: TextStyle(
                      color: gear == 0 ? Colors.greenAccent : const Color(0xFF29B6F6),
                      fontSize: 30,
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
}
