import 'package:doctor_appointment_app/doctors_management/screens/doctor_profile.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_navigation_bar.dart'; // Import the navigation bar

class DoctorHomeScreen extends StatefulWidget {
  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0; // Set the initial index to 0 (Home)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DoctorHomeScreen()));
    }
    if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => DoctorProfileScreen()));
    }
    if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => DoctorAvailabilityScreen()));
    }
  }

  final CollectionReference appointments =
      FirebaseFirestore.instance.collection('Appoitnments');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor Home')),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointments.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No appointments data found.');
            return Center(child: Text('No appointments found'));
          }

          final data = snapshot.requireData;
          print('Appointments count: ${data.size}'); // Debug print

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var appointmentData =
                  data.docs[index].data() as Map<String, dynamic>;
              print('Appointment Data: $appointmentData'); // Debug print
              return Card(
                margin: EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient: ${appointmentData['Patient Name']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Doctor: ${appointmentData['Dr Name']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Time: ${appointmentData['Time']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: DoctorNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
