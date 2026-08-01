import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import '../models/dashboard_data.dart';

class UsbSerialService {
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<DashboardData> _controller = StreamController<DashboardData>.broadcast();

  Stream<DashboardData> get dataStream => _controller.stream;

  Future<void> startListening() async {
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
            } catch (e) {
              // Ignore invalid JSON format
            }
          }
        }
        buffer = lines.last;
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _port?.close();
    _controller.close();
  }
}
