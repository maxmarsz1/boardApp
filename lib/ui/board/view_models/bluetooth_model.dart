
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BluetoothStatus {connected, scanning, off, disconnected}

class BluetoothModel {
  BluetoothStatus status = BluetoothStatus.off;
  StreamSubscription<BluetoothAdapterState>? _subscription;
  List<BluetoothDevice> scannedDevices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? _controlCharacteristic;

  get controlCharacteristic => _controlCharacteristic;
  get subscription => _subscription;

  set setSubscription(StreamSubscription<BluetoothAdapterState>? s){
    _subscription = s;
  }
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