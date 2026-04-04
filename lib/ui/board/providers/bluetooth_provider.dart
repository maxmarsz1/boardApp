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

  BluetoothDevice? getConnectedDevice(){
    return bluetoothModel.connectedDevice;
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

    if (bluetoothModel.subscription == null) {
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
  
  void connect(BluetoothDevice device) async {
    var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
    if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to 
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!

        changeStatus(BluetoothStatus.disconnected);
        bluetoothModel.connectedDevice = null;
        notifyListeners();
        print("${device.disconnectReason?.code} ${device.disconnectReason?.description}");
      }
    });

    // cleanup: cancel subscription when disconnected
    //   - [delayed] This option is only meant for `connectionState` subscriptions.  
    //     When `true`, we cancel after a small delay. This ensures the `connectionState` 
    //     listener receives the `disconnected` event.
    //   - [next] if true, the the stream will be canceled only on the *next* disconnection,
    //     not the current disconnection. This is useful if you setup your subscriptions
    //     before you connect.
    device.cancelWhenDisconnected(subscription, delayed:true, next:true);
    await device.connect(license: License.free);
    bluetoothModel.connectedDevice = device;

    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      // print(service);
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if(c.uuid.str == "77fb628a-5f65-4c9d-aacc-73f499bae991"){
          bluetoothModel.controlCharacteristic = c;
          // print("Found characteristic");
          // c.write([0x33]);
        }
      }
    });

    changeStatus(BluetoothStatus.connected);
    notifyListeners();
  }

  void setSubscription() {
    bluetoothModel.setSubscription = FlutterBluePlus.adapterState.listen((
      BluetoothAdapterState state,
    ) async {
      print("State: $state");
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

  List<BluetoothDevice> getScannedFilteredDevices() {
    List<BluetoothDevice> filteredDevices = bluetoothModel.scannedDevices.where((device) => device.advName == "Board67").toList();
    return filteredDevices;
  }

  void lightBoard(List<int> routeLayoutBytes){
    sendBytes(routeLayoutBytes);
  }

  void sendBytes(List<int> bytes){
    BluetoothCharacteristic characteristic = bluetoothModel.controlCharacteristic;
    characteristic.write(bytes);
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
