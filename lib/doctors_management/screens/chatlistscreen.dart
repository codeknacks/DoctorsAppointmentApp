import 'package:doctor_appointment_app/doctors_management/screens/chatscreen.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_navigation_bar.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_profile.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorChatPatientListScreen extends StatefulWidget {
  @override
  _DoctorChatPatientListScreenState createState() =>
      _DoctorChatPatientListScreenState();
}

class _DoctorChatPatientListScreenState
    extends State<DoctorChatPatientListScreen> {
  int _selectedIndex = 0;
  late String doctorId;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => DoctorHomeScreen()));
    }
    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DoctorProfileScreen()));
    }
    if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DoctorAvailabilityScreen()));
    }
    if (index == 3) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorChatPatientListScreen()));
    }
  }

  Stream<List<Map<String, dynamic>>> getPatientsWithAppointments() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> fetchedPatients = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> patientData = doc.data() as Map<String, dynamic>;
        String patientId = patientData['patientId'];
        String appointmentId = doc.id;

        DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .get();

        if (patientSnapshot.exists) {
          Map<String, dynamic>? patientInfo =
              patientSnapshot.data() as Map<String, dynamic>?;
          String profilePicUrl = patientInfo?['profile_image'] ?? '';

          patientData['profile_image'] = profilePicUrl;
          patientData['appointmentId'] = appointmentId;
          fetchedPatients.add(patientData);
        }
      }

      fetchedPatients.sort((a, b) {
        final aLastMessageTime = a['lastMessageTime'] as Timestamp?;
        final bLastMessageTime = b['lastMessageTime'] as Timestamp?;

        if (aLastMessageTime == null && bLastMessageTime == null) return 0;
        if (aLastMessageTime == null) return 1;
        if (bLastMessageTime == null) return -1;

        return bLastMessageTime.compareTo(aLastMessageTime);
      });

      return fetchedPatients;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    doctorId = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Chat with Patients',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getPatientsWithAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No patients to chat with'));
          }

          var patients = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Patients',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    var patient = patients[index];
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue[50]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            patient['profile_image'] != null &&
                                    patient['profile_image'] != ''
                                ? ClipOval(
                                    child: Image.network(
                                      patient['profile_image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.person, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Patient Name: ${patient['name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.chat, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DoctorChatScreen(
                                              patientName: patient['name'],
                                              patientId: patient['patientId'],
                                              appointmentId:
                                                  patient['appointmentId'],
                                            )));
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: DoctorNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
