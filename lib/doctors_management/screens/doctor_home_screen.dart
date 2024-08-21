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

    // Optionally, notify the patient about the decision
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

// class NotificationScreen extends StatelessWidget {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void _handleAppointment(String appointmentId, bool isAccepted) async {
//     DocumentReference appointmentRef =
//         _firestore.collection('appointments').doc(appointmentId);

//     await appointmentRef.update({
//       'status': isAccepted ? 'accepted' : 'rejected',
//     });

//     // Optionally, notify the patient about the decision
//   }

//   Future<Map<String, dynamic>?> _getPatientData(String patientId) async {
//     DocumentSnapshot patientSnapshot =
//         await _firestore.collection('patients').doc(patientId).get();
//     return patientSnapshot.data() as Map<String, dynamic>?;
//   }

//   @override
//   Widget build(BuildContext context) {
//     User? user = _auth.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(Icons.notifications),
//             SizedBox(width: 8),
//             Text('Notifications'),
//           ],
//         ),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue, Colors.cyan],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('appointments')
//             .where('doctorId', isEqualTo: user!.uid)
//             .where('status', isEqualTo: 'Pending')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           var notifications = snapshot.data?.docs ?? [];

//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               var appointment = notifications[index];
//               var appointmentData = appointment.data() as Map<String, dynamic>;

//               return FutureBuilder<Map<String, dynamic>?>(
//                 future: _getPatientData(appointmentData['patientId']),
//                 builder: (context, patientSnapshot) {
//                   if (!patientSnapshot.hasData) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   var patientData = patientSnapshot.data;

//                   return Card(
//                     elevation: 8,
//                     margin: EdgeInsets.all(10),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.white, Colors.blue[50]!],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                       ),
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.person, color: Colors.blue),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Patient: ${patientData != null ? patientData['name'] ?? 'Unknown' : 'Unknown'}',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Icon(Icons.access_time, color: Colors.blue),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Time: ${appointmentData['appointmentSlot']}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Icon(Icons.calendar_today, color: Colors.blue),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Date: ${appointmentData['appointmentDate']}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: () =>
//                                     _handleAppointment(appointment.id, true),
//                                 icon: const Icon(Icons.check),
//                                 label: const Text("Accept"),
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor: Colors.green,
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               ElevatedButton.icon(
//                                 onPressed: () =>
//                                     _handleAppointment(appointment.id, false),
//                                 icon: Icon(Icons.close),
//                                 label: Text("Reject"),
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
