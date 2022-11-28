import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';

class BleScanner {
  final List<BlueScanResult> _discoveredDevices = [];
  final StreamController<BleScannerState> _streamController = StreamController.broadcast();
  StreamSubscription<BlueScanResult>? _subscription;

  Stream<BleScannerState> get state => _streamController.stream;

  Future<void> startScan() {
    _subscription?.cancel();
    _subscription = QuickBlue.scanResultStream.listen((result) {
      if (result.name.isEmpty) return;
      _discoveredDevices.removeWhere((element) => element.deviceId == result.deviceId);
      _discoveredDevices.add(result);
      _discoveredDevices.sort(((a, b) => a.name.compareTo(b.name)));
      _pushState(BleScannerState(scanInProgress: true, discoveredDevices: _discoveredDevices));
    });
    _discoveredDevices.clear();
    return Future(() {
      _pushState(const BleScannerState(scanInProgress: true));
      QuickBlue.startScan();
    }).then(
      (_) => Future.delayed(const Duration(seconds: 4), () {
        QuickBlue.stopScan();
        _pushState(BleScannerState(discoveredDevices: _discoveredDevices));
      }),
    );
  }

  void stopScan() {
    _subscription?.cancel();
    QuickBlue.stopScan();
    _pushState(BleScannerState(discoveredDevices: _discoveredDevices));
  }

  void dispose() {
    _discoveredDevices.clear();
    _streamController.close();
  }

  void _pushState(BleScannerState state) {
    _streamController.add(state);
  }
}

@immutable
class BleScannerState {
  const BleScannerState({
    this.scanInProgress = false,
    this.discoveredDevices = const [],
  });

  final List<BlueScanResult> discoveredDevices;
  final bool scanInProgress;
}
