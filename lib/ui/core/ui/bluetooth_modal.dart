import 'package:board_app/main.dart';
import 'package:board_app/ui/board/providers/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class BluetoothModal extends StatelessWidget {
  const BluetoothModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 1050,
        height: 300,

        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Bluetooth devices",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            context.watch<BluetoothProvider>().isScanning()
                ? LinearProgressIndicator()
                : SizedBox(height: 4),

            BluetoothDevicesList(),
          ],
        ),
      ),
    );
  }
}

class BluetoothDevicesList extends StatelessWidget {
  const BluetoothDevicesList({super.key});

  @override
  Widget build(BuildContext context) {
    BluetoothDevice? connectedDevice = context
        .watch<BluetoothProvider>()
        .getConnectedDevice();
    List<BluetoothDevice> scannedDevices = context
        .watch<BluetoothProvider>()
        .getScannedFilteredDevices();

    return Expanded(
      child: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (connectedDevice != null &&
                    !scannedDevices.contains(connectedDevice))
                  BluetoothDeviceItem(device: connectedDevice),
                Expanded(
                  child: ListView.builder(
                    itemCount: context
                        .watch<BluetoothProvider>()
                        .getScannedFilteredDevices()
                        .length,
                    itemBuilder: (context, index) {
                      return BluetoothDeviceItem(
                        device: context
                            .watch<BluetoothProvider>()
                            .getScannedFilteredDevices()[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          BluetoothScanButton(),
        ],
      ),
    );
  }
}

class BluetoothScanButton extends StatelessWidget {
  const BluetoothScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      alignment: const Alignment(0, 1),
      child: ElevatedButton(
        onPressed: context.read<BluetoothProvider>().toggleScan,
        child: Text(
          context.watch<BluetoothProvider>().isScanning()
              ? "Stop"
              : "Search devices",
        ),
      ),
    );
  }
}

class BluetoothDeviceItem extends StatelessWidget {
  const BluetoothDeviceItem({super.key, required this.device});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromARGB(255, 22, 22, 22), width: 1),
        ),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.zero),
          ),
          foregroundColor: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.advName == "" ? device.remoteId.str : device.advName,
                style: TextStyle(fontSize: 16),
              ),
              if (device ==
                  context.watch<BluetoothProvider>().getConnectedDevice())
                Text(
                  "Connected",
                  style: TextStyle(
                    color: Color.from(alpha: 1, red: .6, green: .6, blue: .6),
                  ),
                ),
            ],
          ),
        ),
        onPressed: () async {
          if(context.read<BluetoothProvider>().getConnectedDevice() == device){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Already connected to ${device.advName}"),
            ));
          } else {
            if(await context.read<BluetoothProvider>().connect(device)){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Connected to ${device.advName}"),
              ));
            }
          }
          
        },
      ),
    );
  }
}
