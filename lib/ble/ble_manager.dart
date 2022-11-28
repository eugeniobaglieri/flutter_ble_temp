import 'package:ble_temp/ble/ble_device_connector.dart';
import 'package:ble_temp/ble/ble_device_interactor.dart';
import 'package:ble_temp/ble/ble_scanner.dart';

class BleManager {
  final BleDeviceConnector connector = BleDeviceConnector();
  final BleScanner scanner = BleScanner();
  final BleDeviceInteractor interactor = BleDeviceInteractor();

  void dispose() {
    scanner.dispose();
    connector.dispose();
    interactor.dispose();
  }
}
