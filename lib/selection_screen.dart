import 'package:doctor_appointment_app/doctors_management/screens/doctor_login_screen.dart';
import 'package:doctor_appointment_app/pateints_management/pages/login_page.dart';
import 'package:flutter/material.dart';

class UserSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login as')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorLoginScreen()),
                );
              },
              child: Text('Login as Doctor'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login as Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
