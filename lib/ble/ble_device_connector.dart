import 'dart:async';

import 'package:quick_blue/quick_blue.dart';

class BleDeviceConnector {
  BleDeviceConnector() {
    QuickBlue.setConnectionHandler(_connectionStateHandler);
  }

  final StreamController<BleDeviceConnectorState> _connectionStateController =
      StreamController.broadcast();

  Stream<BleDeviceConnectorState> get connectionState =>
      _connectionStateController.stream.asBroadcastStream();

  void connect(String deviceId) {
    QuickBlue.connect(deviceId);
  }

  void disconnect(String deviceId) {
    QuickBlue.disconnect(deviceId);
  }

  void dispose() {
    QuickBlue.setConnectionHandler(null);
    _connectionStateController.close();
  }

  void _connectionStateHandler(String deviceId, BlueConnectionState state) {
    _pushState(BleDeviceConnectorState.fromState(deviceId, state));
  }

  void _pushState(BleDeviceConnectorState state) {
    _connectionStateController.add(state);
  }
}

class BleDeviceConnectorState {
  BleDeviceConnectorState({
    required this.connected,
    required this.deviceId,
  });

  BleDeviceConnectorState.fromState(String devId, BlueConnectionState state)
      : deviceId = devId,
        connected = (state.value == BlueConnectionState.connected.value);

  final bool connected;
  final String deviceId;
}
