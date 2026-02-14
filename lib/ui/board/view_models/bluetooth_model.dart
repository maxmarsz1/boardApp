
enum BluetoothStatus {connected, scanning, off, disconnected}

class BluetoothModel {
  BluetoothStatus status = BluetoothStatus.off;
  List<String> scannedDevices = ["test1", "test2", "test3"];

  void changeStatus(BluetoothStatus newStatus){
    status = newStatus;
  }

  BluetoothModel();
}