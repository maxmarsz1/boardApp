import 'package:flutter/material.dart';
import 'dart:math';

enum HoldType { none, all, feet, start, end }

class Hold extends StatelessWidget {
  const Hold({super.key, this.rotationAngle, required this.image});

  final Image image;
  final int? rotationAngle;

  // @override
  @override
  Widget build(BuildContext context) {

    return Container(
      transformAlignment: Alignment.center,
      transform: Matrix4.rotationZ((rotationAngle ?? 0) * (pi / 180)),
      child: SizedBox(
        width: 40,
        height: 40,
        child: image,
      ),
    );
  }
}