import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/pateints_management/components/apppointment_model.dart';
import 'package:flutter/material.dart';

class AppointmentListPage extends StatefulWidget {
  @override
  _AppointmentListPageState createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Appointment>> _fetchAppointments() async {
    QuerySnapshot querySnapshot = await _firestore.collection('appointments').get();

    return querySnapshot.docs.map((doc) {
      return Appointment.fromFirestore(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Appointments Found'));
          }

          List<Appointment> appointments = snapshot.data!;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${appointment.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Age: ${appointment.age}', style: TextStyle(fontSize: 14)),
                      Text('Appointment Date: ${appointment.appointmentDate}', style: TextStyle(fontSize: 14)),
                      Text('Mobile Number: ${appointment.mobileNumber}', style: TextStyle(fontSize: 14)),
                      Text('Status: ${appointment.status}', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
