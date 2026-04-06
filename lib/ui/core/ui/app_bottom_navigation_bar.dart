import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key, required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueSetter<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Board"),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart_rounded),
          label: "Routes",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
      ],
      onTap: (idx) => onTap(idx),
      currentIndex: selectedIndex,
      backgroundColor: Color.fromARGB(255, 49, 49, 49),
      selectedItemColor: Colors.orangeAccent,
      unselectedItemColor: Colors.white,
    );
  }
}
