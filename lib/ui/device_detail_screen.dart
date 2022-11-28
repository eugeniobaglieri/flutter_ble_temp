import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_blue/quick_blue.dart';

import 'package:ble_temp/ble/ble_device_connector.dart';
import 'package:ble_temp/ble/ble_device_interactor.dart';
import 'package:ble_temp/ble/ble_manager.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BlueScanResult device;

  @override
  Widget build(BuildContext context) {
    BleManager ble = context.read<BleManager>();
    return _DeviceDetail(
      device: device,
      connector: ble.connector,
      interactor: ble.interactor,
    );
  }
}

class _DeviceDetail extends StatefulWidget {
  const _DeviceDetail({
    Key? key,
    required this.connector,
    required this.interactor,
    required this.device,
  }) : super(key: key);

  final BleDeviceConnector connector;
  final BleDeviceInteractor interactor;
  final BlueScanResult device;

  @override
  State<_DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<_DeviceDetail> {
  bool subscribed = false;

  StreamSubscription<BleDeviceConnectorState>? _connectionSubscription;

  StreamSubscription<BleDeviceInteractorState>? _interactionSubscription;

  void _connect() {
    _connectionSubscription = widget.connector.connectionState.listen((state) {
      if (!state.connected) return;
      widget.interactor.discoverServices(state.deviceId);
    });
    _interactionSubscription = widget.interactor.state.listen((state) {
      if (state is BleDeviceInteractorDiscoverService) {
        if (subscribed) return;
        subscribed = true;
        widget.interactor.subScribeTo(
          deviceId: state.deviceId,
          serviceId: '181a',
          characteristicId: '2a6e',
        );
      }
    });
    widget.connector.connect(widget.device.deviceId);
  }

  void _disconnect() {
    _interactionSubscription?.cancel();
    _interactionSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    widget.connector.disconnect(widget.device.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    _connect();
    return WillPopScope(
      onWillPop: () async {
        _disconnect();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.device.name)),
        body: StreamBuilder<BleDeviceConnectorState>(
          stream: widget.connector.connectionState,
          builder: (context, snapshot) {
            final BleDeviceConnectorState connState = snapshot.data ??
                BleDeviceConnectorState(connected: false, deviceId: "");
            if (!connState.connected) {
              return const Center(child: Text("Not Connected"));
            }
            return StreamBuilder<BleDeviceInteractorState>(
              stream: widget.interactor.state,
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text("Data not yet available"));
                }
                BleDeviceInteractorState state = snapshot.data!;
                if (state is BleDeviceInteractorNotifyValue) {
                  var buffer = state.value.buffer;
                  var bytes = buffer.asByteData();
                  double temp = bytes.getInt16(0, Endian.little) / 100;
                  return Center(
                    child: Text(
                      temp.toString(),
                      style: const TextStyle(fontSize: 40.0),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
