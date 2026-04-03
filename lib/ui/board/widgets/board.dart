import 'dart:convert';

import 'package:board_app/ui/board/providers/bluetooth_provider.dart';
import 'package:board_app/ui/board/providers/board_provider.dart';
import 'package:board_app/ui/board/view_models/route_model.dart';
import 'package:board_app/ui/board/widgets/hold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Board extends StatefulWidget {
  const Board({
    super.key,
    required this.holds,
    required this.rows,
    required this.cols,
  });

  final List<Hold> holds;
  final int rows;
  final int cols;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late List<Hold> _holds;

  @override
  void initState() {
    _holds = widget.holds;
    super.initState();
  }

  void _loadRoute() {
    final board = context.read<BoardProvider>();
    try {
      final RouteModel test = RouteModel.fromJson(
        jsonDecode('{"all": [1,2,3], "feet": [33, 42], "start": [12, 13]}'),
      );
      board.changeRoute(test);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardProvider>(
      builder: (context, value, child) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InteractiveViewer(
            // boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.1,
            maxScale: 3.0,
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                Image.asset("assets/boards/board4_3.png"),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20),
                  crossAxisCount: widget.cols,
                  children: List.generate(_holds.length, (index) {
                    return GestureDetector(
                      onTap: () =>
                          context.read<BoardProvider>().changeHoldType(index),
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                // Colors.black
                                context
                                    .read<BoardProvider>()
                                    .route
                                    .getHoldTypeColor(
                                      context
                                          .watch<BoardProvider>()
                                          .route
                                          .getHoldType(index),
                                    ),
                            // _getHoldTypeColor(_getHoldType(index)),
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(child: _holds[index]),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => _loadRoute(),
                child: Text("Load route"),
              ),
              ElevatedButton(
                onPressed: () => {context.read<BluetoothProvider>().lightBoard(context.read<BoardProvider>().route.getRouteLayoutBytes())},
                child: Text("Light board"),
              ),
              ElevatedButton(
                onPressed: () => context.read<BoardProvider>().clearRoute(),
                child: Text("Clear"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
