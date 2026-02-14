
import 'package:board_app/ui/board/view_models/bluetooth_model.dart';
import 'package:flutter/material.dart';

class BluetoothProvider extends ChangeNotifier{
  BluetoothModel bluetoothModel = BluetoothModel();

  BluetoothProvider();

  BluetoothStatus get status => bluetoothModel.status;

  bool isScanning(){
    return bluetoothModel.status == BluetoothStatus.scanning;
  }

  void changeStatus(BluetoothStatus newStatus){
    bluetoothModel.changeStatus(newStatus);
    notifyListeners();
  }

  void toggleScan(){
    bluetoothModel.changeStatus(isScanning() ? BluetoothStatus.disconnected : BluetoothStatus.scanning);
    notifyListeners();
  }

  List<String> getScannedDevices(){
    return bluetoothModel.scannedDevices;
  }

  Icon getBluetoothIcon(){
    IconData icon = switch (status) {
      BluetoothStatus.connected => Icons.bluetooth_connected,
      BluetoothStatus.disconnected => Icons.bluetooth,
      BluetoothStatus.off => Icons.bluetooth_disabled,
      BluetoothStatus.scanning => Icons.bluetooth_searching
    };

    return Icon(icon);
  }
}