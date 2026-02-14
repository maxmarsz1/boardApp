 import 'package:flutter/material.dart';

var defaultTheme = ThemeData(
  scaffoldBackgroundColor: const Color.fromARGB(255, 22, 22, 22),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 49, 49, 49),
    foregroundColor: Colors.white,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    linearTrackColor: Colors.white,
    color: Colors.orangeAccent
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.orangeAccent,
      backgroundColor: Color.fromARGB(255, 49, 49, 49),
      disabledBackgroundColor: Color.fromARGB(255, 49, 49, 49),
      disabledForegroundColor: Colors.grey
    )
  )
);