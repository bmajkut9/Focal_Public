import 'package:flutter/material.dart';


class BottomNavBar extends StatefulWidget {
  final Function(int) onIndexChanged;

  BottomNavBar({Key? key, required this.onIndexChanged}) : super(key: key);
  
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}


class _BottomNavBarState extends State<BottomNavBar> {
  
  int selectedIndex = 0;

  void _updateSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onIndexChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      selectedItemColor: Theme.of(context).colorScheme.onPrimary,
      unselectedItemColor: Theme.of(context).colorScheme.primary,
      currentIndex: selectedIndex,
      onTap: _updateSelectedIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon( 
            Icons.timer,
          ),
          label: "Timer",
  
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2, size: 30),
          label: "Profile",

        ),
      ],
    );
  }
}



