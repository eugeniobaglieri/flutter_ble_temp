import 'dart:async';
import 'dart:typed_data';

import 'package:quick_blue/quick_blue.dart';

class BleDeviceInteractor {
  BleDeviceInteractor() {
    QuickBlue.setServiceHandler(_serviceHandler);
    QuickBlue.setValueHandler(_valueChangeHandler);
  }

  final StreamController<BleDeviceInteractorState> _stateController = StreamController.broadcast();

  Stream<BleDeviceInteractorState> get state => _stateController.stream.asBroadcastStream();

  void discoverServices(String deviceId) {
    QuickBlue.discoverServices(deviceId);
  }

  Future<void> subScribeTo({
    required String deviceId,
    required String serviceId,
    required String characteristicId,
  }) {
    return QuickBlue.setNotifiable(
      deviceId,
      serviceId,
      characteristicId,
      BleInputProperty.notification,
    );
  }

  void dispose() {
    QuickBlue.setServiceHandler(null);
    QuickBlue.setValueHandler(null);
    _stateController.close();
  }

  void _serviceHandler(String deviceId, String serviceId) {
    var state = BleDeviceInteractorDiscoverService(deviceId: deviceId, serviceId: serviceId);
    _pushState(state);
  }

  void _valueChangeHandler(String deviceId, String characteristicId, Uint8List value) {
    var state = BleDeviceInteractorNotifyValue(
        deviceId: deviceId, characteristicId: characteristicId, value: value);
    _pushState(state);
  }

  void _pushState(BleDeviceInteractorState state) {
    _stateController.add(state);
  }
}

abstract class BleDeviceInteractorState {}

class BleDeviceInteractorDiscoverService extends BleDeviceInteractorState {
  BleDeviceInteractorDiscoverService({
    required this.deviceId,
    required this.serviceId,
  });

  final String deviceId;
  final String serviceId;
}

class BleDeviceInteractorNotifyValue extends BleDeviceInteractorState {
  BleDeviceInteractorNotifyValue({
    required this.deviceId,
    required this.characteristicId,
    required this.value,
  });

  final String characteristicId;
  final String deviceId;
  final Uint8List value;
}
