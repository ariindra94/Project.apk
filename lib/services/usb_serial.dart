import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import '../models/dashboard_data.dart';

class UsbSerialService {
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<DashboardData> _dataController = StreamController<DashboardData>.broadcast();
  String _buffer = "";

  Stream<DashboardData> get dataStream => _dataController.stream;

  void startListening() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return;

    _port = await devices.first.create();
    bool openResult = await _port!.open();
    if (!openResult) return;

    await _port!.setDtr(true);
    await _port!.setRts(true);
    await _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _subscription = _port!.inputStream!.listen((Uint8List data) {
      _processData(data);
    });
  }

  void _processData(Uint8List data) {
    String incomingString = utf8.decode(data, allowMalformed: true);
    _buffer += incomingString;

    while (_buffer.contains('\n')) {
      int index = _buffer.indexOf('\n');
      String rawJson = _buffer.substring(0, index).trim();
      _buffer = _buffer.substring(index + 1);

      if (rawJson.startsWith('{') && rawJson.endsWith('}')) {
        try {
          Map<String, dynamic> parsedJson = jsonDecode(rawJson);
          DashboardData dashboardData = DashboardData.fromJson(parsedJson);
          _dataController.add(dashboardData);
        } catch (e) {
          // Ignore invalid packets
        }
      }
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _port?.close();
  }
}
