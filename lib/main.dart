import 'package:board_app/ui/board/providers/bluetooth_provider.dart';
import 'package:board_app/ui/board/providers/board_provider.dart';
import 'package:board_app/ui/board/widgets/board_random.dart';
import 'package:board_app/ui/core/ui/app_bottom_navigation_bar.dart';
import 'package:board_app/ui/core/ui/themes/default_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BoardProvider()),
        ChangeNotifierProvider(create: (context) => BluetoothProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    BoardRandom(cols: 8, rows: 8),
    Icon(Icons.abc),
    Icon(Icons.person),
  ];

  void _onBottomNavigationTap(int idx) {
    setState(() {
      _selectedIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: BoardAppBar(),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: AppBottomNavigationBar(
          onTap: _onBottomNavigationTap,
          selectedIndex: _selectedIndex,
        ),
      ),
    );
  }
}

class BoardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BoardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Text("Board", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("App", style: TextStyle(fontWeight: FontWeight.w200)),
        ],
      ),
      actions: [
        Consumer<BluetoothProvider>(
          builder: (context, value, child) => IconButton(
            onPressed: () {
              showModalBottomSheet(
                elevation: 1,
                backgroundColor: Color.fromARGB(255, 49, 49, 49),
                context: context,
                builder: (BuildContext context) {
                  return BluetoothModal();
                },
              );
            },
            icon: context.watch<BluetoothProvider>().getBluetoothIcon(),
          ),
        ),
      ],
    );
  }
}

class BluetoothModal extends StatelessWidget {
  const BluetoothModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 1050,
        height: 800,

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
    return Expanded(
      child: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 22, 22, 22),
            child: ListView.builder(
              itemCount: context
                  .watch<BluetoothProvider>()
                  .getScannedDevices()
                  .length,
              itemBuilder: (context, index) {
                return BluetoothDeviceItem(index: index);
              },
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
        onPressed: 
        // context.read<BluetoothProvider>().isScanning()
        //     ? null
        //     : 
            context.read<BluetoothProvider>().toggleScan,
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
  const BluetoothDeviceItem({super.key, required this.index});

  final int index;

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
          padding: const EdgeInsets.all(10),
          child: context.watch<BluetoothProvider>().getScannedDevices()[index].advName == "" ?
            Text(context.watch<BluetoothProvider>().getScannedDevices()[index].remoteId.str) :
            Text(context.watch<BluetoothProvider>().getScannedDevices()[index].advName)
        ),
        onPressed: () {
          BluetoothDevice device = context.read<BluetoothProvider>().getScannedDevices()[index];
          print(
            "Connecting to $device",
          );
          context.read<BluetoothProvider>().connect(device);
        },
      ),
    );
  }
}
