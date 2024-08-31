import 'package:doctor_appointment_app/doctors_management/screens/doctor_navigation_bar.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_profile.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctors_availability.dart';
import 'package:doctor_appointment_app/doctors_management/screens/chatlistscreen.dart';
import 'package:doctor_appointment_app/notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorHomeScreen extends StatefulWidget {
  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;
  late String doctorId;
  int notificationCount = 0;

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

  List<Map<String, dynamic>> upcomingAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUpcomingAppointments();
    _fetchNotificationCount();
  }

  void _fetchUpcomingAppointments() async {
    User? user = _auth.currentUser;
    if (user != null) {
      doctorId = user.uid;
      QuerySnapshot appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'accepted')
          .get();
      setState(() {
        upcomingAppointments = appointmentsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    }
  }

  void _fetchNotificationCount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot notificationsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Pending')
          .get();
      setState(() {
        notificationCount = notificationsSnapshot.docs.length;
      });
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationScreen()),
    ).then((_) {
      _fetchNotificationCount();
    });
  }

  Future<String?> _getPatientProfilePic(String patientId) async {
    DocumentSnapshot patientSnapshot =
        await _firestore.collection('patients').doc(patientId).get();
    Map<String, dynamic>? data =
        patientSnapshot.data() as Map<String, dynamic>?;
    return data?['profile_image'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '  Home',
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
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: _openNotifications,
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                            child: Text(
                          '$notificationCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ))),
                  ),
              ],
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Upcoming Appointments',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                  ),
                  Expanded(
                    child: upcomingAppointments.isEmpty
                        ? Center(child: Text('No upcoming appointments'))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: upcomingAppointments.length,
                            itemBuilder: (context, index) {
                              var appointment = upcomingAppointments[index];
                              return FutureBuilder<String?>(
                                future: _getPatientProfilePic(
                                    appointment['patientId']),
                                builder: (context, snapshot) {
                                  String? profilePic = snapshot.data;

                                  return Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    margin: EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.blue[50]!
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: profilePic != null
                                                ? NetworkImage(profilePic)
                                                : null,
                                            child: profilePic == null
                                                ? Icon(Icons.person,
                                                    color: Colors.white)
                                                : null,
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Patient: ${appointment['name']}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Time: ${appointment['appointmentSlot']}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Date: ${appointment['appointmentDate']}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
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
                  ),
                ],
              ),
        bottomNavigationBar: DoctorNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ));
  }
}

class NotificationScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _handleAppointment(String appointmentId, bool isAccepted) async {
    DocumentReference appointmentRef =
        _firestore.collection('appointments').doc(appointmentId);

    await appointmentRef.update({
      'status': isAccepted ? 'accepted' : 'rejected',
    });

    if (isAccepted) {
      await _generatePaymentReceipt(appointmentId);
    }

    // Optionally, notify the patient about the decision
  }

  Future<void> _generatePaymentReceipt(String appointmentId) async {
    try {
      DocumentSnapshot appointmentSnapshot =
          await _firestore.collection('appointments').doc(appointmentId).get();
      Map<String, dynamic> appointmentData =
          appointmentSnapshot.data() as Map<String, dynamic>;

      DocumentSnapshot doctorSnapshot = await _firestore
          .collection('doctors')
          .doc(appointmentData['doctorId'])
          .get();
      Map<String, dynamic> doctorData =
          doctorSnapshot.data() as Map<String, dynamic>;

      // Extract start and end times
      String appointmentSlot = appointmentData['appointmentSlot'];
      List<String> times = appointmentSlot.split('-');
      String startTimeString = times[0].trim();
      String endTimeString = times[1].trim();

      // Calculate duration in minutes
      int startMinutes = _getMinutesFromTime(startTimeString);
      int endMinutes = _getMinutesFromTime(endTimeString);

      // If the end time was "12:00", adjust to 60 minutes
      if (endMinutes % 60 == 0 && startMinutes > endMinutes) {
        endMinutes += 60;
      }

      int durationInMinutes = endMinutes - startMinutes;

      // Calculate the payment based on the doctor's rate
      double ratePerHour = doctorData['ratePerHour'];
      double durationInHours = durationInMinutes / 60.0;
      double fee = ratePerHour * durationInHours;
      double commission = fee * 0.05;
      double doctorAmount = fee - commission;

      // Store payment details
      await _firestore.collection('payments').add({
        'appointmentId': appointmentId,
        'patientId': appointmentData['patientId'],
        'doctorId': appointmentData['doctorId'],
        'amount': fee,
        'commission': commission,
        'doctorAmount': doctorAmount,
        'status': 'pending',
        'createdAt': DateTime.now(),
      });

      print("Payment details stored successfully.");
    } catch (e) {
      print("Error generating payment receipt: $e");
    }
  }

  int _getMinutesFromTime(String timeString) {
    // Correcting possible issues with AM/PM spacing
    timeString = timeString.replaceAllMapped(
        RegExp(r'(\d+)(am|pm)', caseSensitive: false),
        (Match m) => '${m[1]} ${m[2]?.toUpperCase()}');

    // Extract hours and minutes from the time string
    final timeParts = timeString.split(':');
    int hours = int.parse(timeParts[0].trim());
    int minutes = int.parse(timeParts[1].split(' ')[0].trim());
    String period = timeString.split(' ')[1].trim().toUpperCase();

    // Convert to 24-hour format if necessary
    if (period == 'PM' && hours != 12) {
      hours += 12;
    } else if (period == 'AM' && hours == 12) {
      hours = 0;
    }

    return hours * 60 + minutes;
  }

  Future<Map<String, dynamic>?> _getPatientData(String patientId) async {
    DocumentSnapshot patientSnapshot =
        await _firestore.collection('patients').doc(patientId).get();
    return patientSnapshot.data() as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Please log in to view notifications"),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.notifications),
            SizedBox(width: 8),
            Text('Notifications'),
          ],
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var appointment = notifications[index];
              var appointmentData = appointment.data() as Map<String, dynamic>;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getPatientData(appointmentData['patientId']),
                builder: (context, patientSnapshot) {
                  if (!patientSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var patientData = patientSnapshot.data;

                  return Card(
                    elevation: 8,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            child: patientData != null &&
                                    patientData['profile_image'] != null
                                ? null
                                : Icon(Icons.person, color: Colors.white),
                            backgroundImage: patientData != null &&
                                    patientData['profile_image'] != null
                                ? NetworkImage(patientData['profile_image'])
                                : null,
                            backgroundColor: Colors.blueAccent,
                          ),
                          title: Text(
                            patientData != null
                                ? patientData['name'] ?? 'Unknown'
                                : 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Date: ${appointmentData['appointmentDate']}'),
                              Text(
                                  'Time: ${appointmentData['appointmentSlot']}'),
                            ],
                          ),
                        ),
                        ButtonBar(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _handleAppointment(appointment.id, true),
                              icon: Icon(Icons.check),
                              label: Text("Accept"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _handleAppointment(appointment.id, false),
                              icon: Icon(Icons.close),
                              label: Text("Reject"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
