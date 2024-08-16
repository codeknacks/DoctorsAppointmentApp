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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  void _fetchPatients() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Pending')
          .get();

      List<Map<String, dynamic>> fetchedPatients = [];

      for (var doc in appointmentsSnapshot.docs) {
        Map<String, dynamic> patientData = doc.data() as Map<String, dynamic>;

        // Fetch profile picture URL from the 'patients' collection
        String patientId = patientData['patientId'];
        DocumentSnapshot patientSnapshot =
            await _firestore.collection('patients').doc(patientId).get();

        if (patientSnapshot.exists) {
          Map<String, dynamic>? patientInfo =
              patientSnapshot.data() as Map<String, dynamic>?;
          String profilePicUrl = patientInfo?['profile_image'] ?? '';

          // Add profilePicUrl to patientData
          patientData['profile_image'] = profilePicUrl;
          fetchedPatients.add(patientData);
        }
      }

      setState(() {
        patients = fetchedPatients;
        isLoading = false;
      });
    }
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                  child: patients.isEmpty
                      ? Center(child: Text('No patients to chat with'))
                      : ListView.builder(
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
                                    // Display profile picture or fallback to an icon if unavailable
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
                                        : Icon(Icons.person,
                                            color: Colors.blue),
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
                                      icon:
                                          Icon(Icons.chat, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DoctorChatScreen(
                                                      patientName:
                                                          patient['name'],
                                                      patientId:
                                                          patient['patientId'],
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
