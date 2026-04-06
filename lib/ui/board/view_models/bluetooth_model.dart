
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BluetoothStatus {connected, on, off}

class BluetoothModel {
  BluetoothStatus status = BluetoothStatus.off;
  StreamSubscription<BluetoothAdapterState>? adapterStateSubscription;
  List<BluetoothDevice> scannedDevices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? _controlCharacteristic;
  bool isScanning = false;

  get controlCharacteristic => _controlCharacteristic;

  set controlCharacteristic(BluetoothCharacteristic controlCharacteristic){
    _controlCharacteristic = controlCharacteristic;
  }

  void changeStatus(BluetoothStatus newStatus){
    status = newStatus;
  }

  void newScannedDevice(BluetoothDevice newDevice){
    if(!scannedDevices.contains(newDevice)){
      scannedDevices.add(newDevice);
    }
  }

  void clearScannedDevices(){
    scannedDevices = [];
  }


  BluetoothModel();
}