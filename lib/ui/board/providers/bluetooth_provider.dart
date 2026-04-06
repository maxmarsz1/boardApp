import 'dart:io';

import 'package:board_app/ui/board/view_models/bluetooth_model.dart';
import 'package:board_app/ui/board/view_models/route_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider extends ChangeNotifier {
  BluetoothModel bluetoothModel = BluetoothModel();
  final BuildContext context;

  BluetoothProvider(this.context){
    bluetoothModel.adapterStateSubscription = FlutterBluePlus.adapterState.listen((
      BluetoothAdapterState state,
    ) async {
      print("State: $state");
      if (state == BluetoothAdapterState.on) {
        // Wait for Bluetooth enabled & permission granted
        // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
        await FlutterBluePlus.adapterState
            .where((val) => val == BluetoothAdapterState.on)
            .first;

        bluetoothModel.changeStatus(BluetoothStatus.on);
        notifyListeners();
      } else if (state == BluetoothAdapterState.off) {
        bluetoothModel.changeStatus(BluetoothStatus.off);
        notifyListeners();
      }
    });
  }

  BluetoothStatus get status => bluetoothModel.status;

  bool isScanning() {
    return bluetoothModel.isScanning;
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

    if (isScanning()) {
      await FlutterBluePlus.stopScan();
      bluetoothModel.isScanning = false;
      notifyListeners();
    } else {
      bluetoothModel.clearScannedDevices();

      var scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
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
      FlutterBluePlus.cancelWhenScanComplete(scanSubscription);


      // Start scanning w/ timeout
      // Optional: use `stopScan()` as an alternative to timeout
      await FlutterBluePlus.startScan(
        // withServices:[Guid("180D")], // match any of the specified services
        // withNames:["Bluno"], // *or* any of the specified names
        timeout: Duration(seconds:15)
      );
      bluetoothModel.isScanning = true;
      notifyListeners();

      // wait for scanning to stop
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
      bluetoothModel.isScanning = false;
      notifyListeners();
    }

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }
  
  Future<bool> connect(BluetoothDevice device) async {
    var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
    if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to 
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!

        changeStatus(BluetoothStatus.on);
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
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if(c.uuid.str == "77fb628a-5f65-4c9d-aacc-73f499bae991"){
          bluetoothModel.controlCharacteristic = c;
        }
      }
    });

    changeStatus(BluetoothStatus.connected);
    notifyListeners();

    // todo: figure out when device connected succesfuly and when it didn't
    return true;
  }

  List<BluetoothDevice> getScannedFilteredDevices() {
    List<BluetoothDevice> filteredDevices = bluetoothModel.scannedDevices.where((device) => device.advName == "Board67").toList();
    return filteredDevices;
  }

  void lightBoard(RouteModel route, BuildContext context){
    if(bluetoothModel.connectedDevice != null){
      sendBytes(route.getRouteLayoutBytes());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Not connected to any board."),
      ));
    }
  }

  void sendBytes(List<int> bytes){
    BluetoothCharacteristic characteristic = bluetoothModel.controlCharacteristic;
    characteristic.write(bytes);
  }

  Icon getBluetoothIcon() {
    IconData icon = switch (status) {
      BluetoothStatus.connected => Icons.bluetooth_connected,
      BluetoothStatus.off => Icons.bluetooth_disabled,
      _ => Icons.bluetooth,
    };

    return Icon(icon);
  }
}
