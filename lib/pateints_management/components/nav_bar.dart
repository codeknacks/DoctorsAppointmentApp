import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/pateints_management/pages/chat_show.dart';
import 'package:doctor_appointment_app/pateints_management/pages/display_appointment.dart';
import 'package:doctor_appointment_app/pateints_management/pages/homepage.dart';
import 'package:doctor_appointment_app/pateints_management/pages/profile_pateint.dart';

class NavBAr extends StatefulWidget {
  const NavBAr({Key? key}) : super(key: key);

  @override
  State<NavBAr> createState() => _NavBArState();
}

class _NavBArState extends State<NavBAr> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pageWidgets = [
      HomePage(),
      PatientProfilePage(),
      BookedAppointmentsPage(),
      ChatOverviewPage(), 
    ];

    return Scaffold(
      body: _pageWidgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: const Color.fromARGB(255, 154, 223, 255),
        unselectedItemColor: const Color.fromARGB(255, 255, 253, 253),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10, color: Colors.white70),
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
