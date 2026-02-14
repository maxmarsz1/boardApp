import 'dart:math';

import 'package:board_app/ui/board/widgets/board.dart';
import 'package:board_app/ui/board/widgets/hold.dart';
import 'package:flutter/material.dart';


class BoardRandom extends StatefulWidget {
  const BoardRandom({super.key, this.cols = 10, this.rows = 10});

  final int rows;
  final int cols;

  @override
  State<BoardRandom> createState() => _BoardRandomState();
}

class _BoardRandomState extends State<BoardRandom> {
  late List<Hold> _holds;

  Hold generateRandomHold() {
    String imgPath = "";

    if (Random().nextBool()) {
      //crimp - range 4-24
      imgPath = "assets/holds/crimp_${Random().nextInt(20) + 4}.png";
    } else {
      //jug - range 3-22
      imgPath = "assets/holds/jug_${Random().nextInt(20) + 3}.png";
    }
    return Hold(
        image: Image.asset(imgPath),
        rotationAngle: Random().nextInt(3) * 45 - 45,
      );
  }



  @override
  void initState() {
    _holds = List.generate(
      widget.cols * widget.rows,
      (index) => generateRandomHold(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Board(holds: _holds, rows: widget.rows, cols: widget.cols);
  }
}