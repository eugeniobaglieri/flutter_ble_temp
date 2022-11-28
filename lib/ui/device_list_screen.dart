import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_blue/quick_blue.dart';

import 'package:ble_temp/ble/ble_manager.dart';
import 'package:ble_temp/ble/ble_scanner.dart';
import 'package:ble_temp/ui/device_detail_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BleManager ble = context.read<BleManager>();
    return _DeviceList(scanner: ble.scanner);
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({
    Key? key,
    required this.scanner,
  }) : super(key: key);

  final BleScanner scanner;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BleScannerState>(
      stream: scanner.state,
      initialData: const BleScannerState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        final BleScannerState state = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text("Device List")),
          floatingActionButton: FloatingActionButton(
            onPressed:
                state.scanInProgress ? scanner.stopScan : scanner.startScan,
            child: const Icon(Icons.search),
          ),
          body: ListView.separated(
              itemCount: state.discoveredDevices.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: ((context, index) {
                final BlueScanResult device = state.discoveredDevices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.name),
                  subtitle: Text(device.deviceId),
                  trailing: Text(device.rssi.toString()),
                  onTap: () async {
                    scanner.stopScan();
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DeviceDetailScreen(device: device)),
                    );
                  },
                );
              })),
        );
      },
    );
  }
}
