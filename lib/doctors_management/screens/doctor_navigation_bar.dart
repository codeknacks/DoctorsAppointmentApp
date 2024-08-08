import 'package:flutter/material.dart';

class DoctorNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  DoctorNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blueAccent, // Highlighted active icon color
      unselectedItemColor: Colors.grey, // Color for inactive icons
      showUnselectedLabels: true, // Show labels for all icons
      items: [
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.calendar_today),
          label: 'Availability',
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.black,
          icon: Icon(Icons.people),
          label: 'Patients',
        ),
      ],
    );
  }
}
