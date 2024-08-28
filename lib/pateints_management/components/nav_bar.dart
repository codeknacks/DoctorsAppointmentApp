import 'package:flutter/material.dart';

import 'package:doctor_appointment_app/pateints_management/pages/display_appointment.dart';
import 'package:doctor_appointment_app/pateints_management/pages/homepage.dart';
import 'package:doctor_appointment_app/pateints_management/pages/profile_pateint.dart';

class NavBAr extends StatefulWidget {

  const NavBAr({Key? key,}) : super(key: key);

  @override
  State<NavBAr> createState() => _NavBArState();
}

class _NavBArState extends State<NavBAr> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List of pages with patientId passed where needed
    final List<Widget> _pageWidgets = [
      HomePage(),
      PatientProfilePage(),
      BookedAppointmentsPage(), // Pass patientId here
    ];

    return Scaffold(
      body: _pageWidgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color.fromARGB(255, 154, 223, 255),
        unselectedItemColor: const Color.fromARGB(255, 255, 253, 253),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer_sharp),
            label: 'Appointments',
          ),
        ],
      ),
    );
  }
}
