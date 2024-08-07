// // import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
// // import 'package:doctor_appointment_app/doctors_management/screens/doctor_navigation_bar.dart';
// // import 'package:doctor_appointment_app/doctors_management/screens/doctor_profile.dart';
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';

// // class DoctorAvailabilityScreen extends StatefulWidget {
// //   @override
// //   _DoctorAvailabilityScreenState createState() =>
// //       _DoctorAvailabilityScreenState();
// // }

// // class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
// //   int _selectedIndex = 2;

// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //     if (index == 0) {
// //       Navigator.push(
// //           context, MaterialPageRoute(builder: (context) => DoctorHomeScreen()));
// //     }
// //     if (index == 1) {
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (context) => DoctorProfileScreen()));
// //     }
// //     if (index == 2) {
// //       Navigator.push(context,
// //           MaterialPageRoute(builder: (context) => DoctorAvailabilityScreen()));
// //     }
// //   }

// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   TextEditingController _slotController = TextEditingController();
// //   List<Map<String, dynamic>> slots = [];
// //   bool isLoading = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchExistingSlots();
// //   }

// //   void _fetchExistingSlots() async {
// //     User? user = _auth.currentUser;
// //     if (user != null) {
// //       DocumentSnapshot doctorSnapshot =
// //           await _firestore.collection('doctors').doc(user.uid).get();
// //       if (doctorSnapshot.exists && doctorSnapshot.data() != null) {
// //         Map<String, dynamic>? data =
// //             doctorSnapshot.data() as Map<String, dynamic>?;
// //         if (data != null && data['availableSlots'] != null) {
// //           setState(() {
// //             slots = List<Map<String, dynamic>>.from(data['availableSlots']);
// //           });
// //         }
// //       }
// //     }
// //   }

// //   void _addSlot() {
// //     if (_slotController.text.isNotEmpty) {
// //       setState(() {
// //         slots.add(
// //             {'slot': _slotController.text, 'booked': false, 'patient': null});
// //         _slotController.clear();
// //       });
// //     }
// //   }

// //   void _saveSlots() async {
// //     setState(() {
// //       isLoading = true;
// //     });

// //     User? user = _auth.currentUser;
// //     if (user != null) {
// //       await _firestore.collection('doctors').doc(user.uid).set({
// //         'availableSlots': slots,
// //       }, SetOptions(merge: true));
// //     }

// //     setState(() {
// //       isLoading = false;
// //     });

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Slots saved successfully!')),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Set Availability"),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _slotController,
// //                     decoration: InputDecoration(
// //                       labelText: 'Enter time slot (e.g., 9-10 AM)',
// //                     ),
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: Icon(Icons.add),
// //                   onPressed: _addSlot,
// //                 ),
// //               ],
// //             ),
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: slots.length,
// //                 itemBuilder: (context, index) {
// //                   var slot = slots[index];
// //                   return ListTile(
// //                     title: Text(slot['slot']),
// //                     subtitle: slot['booked']
// //                         ? Text('Booked by: ${slot['patient']}')
// //                         : Text('Available'),
// //                     trailing: slot['booked']
// //                         ? null
// //                         : IconButton(
// //                             icon: Icon(Icons.delete),
// //                             onPressed: () {
// //                               setState(() {
// //                                 slots.removeAt(index);
// //                               });
// //                             },
// //                           ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             isLoading
// //                 ? CircularProgressIndicator()
// //                 : ElevatedButton(
// //                     onPressed: _saveSlots,
// //                     child: Text("Save Slots"),
// //                   ),
// //           ],
// //         ),
// //       ),
// //       bottomNavigationBar: DoctorNavigationBar(
// //         currentIndex: _selectedIndex,
// //         onTap: _onItemTapped,
// //       ),
// //     );
// //   }
// // }

// import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
// import 'package:doctor_appointment_app/doctors_management/screens/doctor_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'doctor_navigation_bar.dart'; // Ensure this is the correct import for the navigation bar

// class DoctorAvailabilityScreen extends StatefulWidget {
//   @override
//   _DoctorAvailabilityScreenState createState() =>
//       _DoctorAvailabilityScreenState();
// }

// class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
//   int _selectedIndex = 2;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     if (index == 0) {
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => DoctorHomeScreen()));
//     }
//     if (index == 1) {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => DoctorProfileScreen()));
//     }
//     if (index == 2) {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => DoctorAvailabilityScreen()));
//     }
//   }

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   TextEditingController _slotController = TextEditingController();
//   List<Map<String, dynamic>> slots = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchExistingSlots();
//   }

//   void _fetchExistingSlots() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot doctorSnapshot =
//           await _firestore.collection('doctors').doc(user.uid).get();
//       if (doctorSnapshot.exists && doctorSnapshot.data() != null) {
//         Map<String, dynamic>? data =
//             doctorSnapshot.data() as Map<String, dynamic>?;
//         if (data != null && data['availableSlots'] != null) {
//           setState(() {
//             slots = List<Map<String, dynamic>>.from(data['availableSlots']);
//           });
//         }
//       }
//     }
//   }

//   void _addSlot() {
//     if (_slotController.text.isNotEmpty) {
//       setState(() {
//         slots.add(
//             {'slot': _slotController.text, 'booked': false, 'patient': null});
//         _slotController.clear();
//       });
//     }
//   }

//   void _saveSlots() async {
//     setState(() {
//       isLoading = true;
//     });

//     User? user = _auth.currentUser;
//     if (user != null) {
//       await _firestore.collection('doctors').doc(user.uid).set({
//         'availableSlots': slots,
//       }, SetOptions(merge: true));
//     }

//     setState(() {
//       isLoading = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Slots saved successfully!')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Set Availability"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _slotController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter time slot (e.g., 9-10 AM)',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: _addSlot,
//                 ),
//               ],
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: slots.length,
//                 itemBuilder: (context, index) {
//                   var slot = slots[index];
//                   return ListTile(
//                     title: Text(slot['slot']),
//                     subtitle: slot['booked']
//                         ? Text('Booked by: ${slot['patient']}')
//                         : Text('Available'),
//                     trailing: slot['booked']
//                         ? null
//                         : IconButton(
//                             icon: Icon(Icons.delete),
//                             onPressed: () {
//                               setState(() {
//                                 slots.removeAt(index);
//                               });
//                             },
//                           ),
//                   );
//                 },
//               ),
//             ),
//             isLoading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _saveSlots,
//                     child: Text("Save Slots"),
//                   ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: DoctorNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

import 'package:doctor_appointment_app/doctors_management/screens/doctor_home_screen.dart';
import 'package:doctor_appointment_app/doctors_management/screens/doctor_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctor_navigation_bar.dart'; // Ensure this is the correct import for the navigation bar

class DoctorAvailabilityScreen extends StatefulWidget {
  @override
  _DoctorAvailabilityScreenState createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  int _selectedIndex = 2;

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
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _slotController = TextEditingController();
  List<Map<String, dynamic>> slots = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingSlots();
  }

  void _fetchExistingSlots() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doctorSnapshot =
          await _firestore.collection('doctors').doc(user.uid).get();
      if (doctorSnapshot.exists && doctorSnapshot.data() != null) {
        Map<String, dynamic>? data =
            doctorSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data['availableSlots'] != null) {
          setState(() {
            slots = List<Map<String, dynamic>>.from(data['availableSlots']);
          });
        }
      }
    }
  }

  void _addSlot() {
    if (_slotController.text.isNotEmpty) {
      setState(() {
        slots.add(
            {'slot': _slotController.text, 'booked': false, 'patient': null});
        _slotController.clear();
      });
    }
  }

  void _saveSlots() async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;
    print(FirebaseAuth.instance.currentUser!.uid);
    if (user != null) {
      DocumentReference doctorRef =
          _firestore.collection('doctors').doc(user.uid);
      await doctorRef.set({
        'availableSlots': slots,
      });
    }

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Slots saved successfully!')),
    );
  }

  void _deleteSlot(int index) {
    setState(() {
      slots.removeAt(index);
    });

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference doctorRef =
          _firestore.collection('doctors').doc(user.uid);
      doctorRef.update({
        'availableSlots': slots,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set Availability"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _slotController,
                    decoration: InputDecoration(
                      labelText: 'Enter time slot (e.g., 9-10 AM)',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addSlot,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  var slot = slots[index];
                  return ListTile(
                    title: Text(slot['slot']),
                    subtitle: slot['booked']
                        ? Text('Booked by: ${slot['patient']}')
                        : Text('Available'),
                    trailing: slot['booked']
                        ? null
                        : IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteSlot(index);
                            },
                          ),
                  );
                },
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveSlots,
                    child: Text("Save Slots"),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
