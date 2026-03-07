import 'dart:io';

import 'package:board_app/ui/board/view_models/bluetooth_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider extends ChangeNotifier {
  BluetoothModel bluetoothModel = BluetoothModel();

  BluetoothProvider();

  BluetoothStatus get status => bluetoothModel.status;

  bool isScanning() {
    return bluetoothModel.status == BluetoothStatus.scanning;
  }

  void changeStatus(BluetoothStatus newStatus) {
    bluetoothModel.changeStatus(newStatus);
    notifyListeners();
  }

  void toggleScan() async {
    print("Toggling scan");
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    if (bluetoothModel.getSubscription == null) {
      bluetoothModel.clearScannedDevices();
      setSubscription();
    } else {
      await FlutterBluePlus.stopScan();
      bluetoothModel.setSubscription = null;
      notifyListeners();
    }

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }
  
  void connect(){
    changeStatus(BluetoothStatus.connected);
    notifyListeners();
  }

  void setSubscription() {
    bluetoothModel.setSubscription = FlutterBluePlus.adapterState.listen((
      BluetoothAdapterState state,
    ) async {
      print("State: ${state}");
      if (state == BluetoothAdapterState.on) {
        bluetoothModel.changeStatus(
          isScanning()
              ? BluetoothStatus.disconnected
              : BluetoothStatus.scanning,
        );
        var subscription1 = FlutterBluePlus.onScanResults.listen((results) {
          if (results.isNotEmpty) {
            ScanResult r = results.last; // the most recently found device
            print(
              '${r.device.remoteId}: "${r.advertisementData.advName}" found!',
            );
            bluetoothModel.newScannedDevice(r.device);
            notifyListeners();
          }
        }, onError: (e) => print(e));

        // cleanup: cancel subscription when scanning stops
        FlutterBluePlus.cancelWhenScanComplete(subscription1);

        // Wait for Bluetooth enabled & permission granted
        // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
        await FlutterBluePlus.adapterState
            .where((val) => val == BluetoothAdapterState.on)
            .first;

        // Start scanning w/ timeout
        // Optional: use `stopScan()` as an alternative to timeout
        await FlutterBluePlus.startScan(
          // withServices:[Guid("180D")], // match any of the specified services
          // withNames:["Bluno"], // *or* any of the specified names
          // timeout: Duration(seconds:15)
        );

        // wait for scanning to stop
        await FlutterBluePlus.isScanning.where((val) => val == false).first;
        bluetoothModel.changeStatus(
          isScanning()
              ? BluetoothStatus.disconnected
              : BluetoothStatus.scanning,
        );
        notifyListeners();
      } else {
        print("huh?");
        // show an error to the user, etc
      }
    });
  }

  List<BluetoothDevice> getScannedDevices() {
    return bluetoothModel.scannedDevices;
  }

  Icon getBluetoothIcon() {
    IconData icon = switch (status) {
      BluetoothStatus.connected => Icons.bluetooth_connected,
      BluetoothStatus.disconnected => Icons.bluetooth,
      BluetoothStatus.off => Icons.bluetooth_disabled,
      BluetoothStatus.scanning => Icons.bluetooth_searching,
    };

    return Icon(icon);
  }
}
