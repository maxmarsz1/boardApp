
import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BluetoothStatus {connected, scanning, off, disconnected}

class BluetoothModel {
  BluetoothStatus status = BluetoothStatus.off;
  StreamSubscription<BluetoothAdapterState>? _subscription;
  List<BluetoothDevice> scannedDevices = [];

  void changeStatus(BluetoothStatus newStatus){
    status = newStatus;
  }

  set setSubscription(StreamSubscription<BluetoothAdapterState>? s){
    _subscription = s;
  }
  
  get getSubscription => _subscription;

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