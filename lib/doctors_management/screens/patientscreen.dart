import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctor_home_screen.dart';
import 'doctor_profile.dart';
import 'doctor_navigation_bar.dart';
import 'doctors_availability.dart';

class DummyPatientScreen extends StatefulWidget {
  final String doctorId;

  DummyPatientScreen({required this.doctorId});

  @override
  _DummyPatientScreenState createState() => _DummyPatientScreenState();
}

class _DummyPatientScreenState extends State<DummyPatientScreen> {
  int _selectedIndex = 3;
  DateTime? selectedDate;
  String? selectedSlot;
  bool isLoading = false;

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
              builder: (context) => DummyPatientScreen(
                    doctorId: widget.doctorId,
                  )));
    }
  }

  // Fetch doctor's available slots from Firebase
  Future<List<String>> _fetchAvailableSlots() async {
    DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .get();
    if (doctorSnapshot.exists) {
      Map<String, dynamic>? data =
          doctorSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data['availableSlots'] != null) {
        List<dynamic> slots = data['availableSlots'];
        return slots.cast<String>();
      }
    }
    return [];
  }

  // Send appointment request
  Future<void> _sendAppointmentRequest() async {
    if (selectedDate == null || selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time slot')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': widget.doctorId,
        'patientId': user.uid,
        'patientName': user.displayName ?? 'Anonymous',
        'appointmentTime': Timestamp.fromDate(selectedDate!),
        'slot': selectedSlot,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment request sent!')),
      );
    }
  }

  // Select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Available Slots'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<String>>(
              future: _fetchAvailableSlots(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading slots'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No available slots'));
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Select a Date'),
                        subtitle: Text(selectedDate == null
                            ? 'No date selected'
                            : '${selectedDate!.toLocal()}'.split(' ')[0]),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      ListTile(
                        title: Text('Select a Time Slot'),
                        trailing: DropdownButton<String>(
                          value: selectedSlot,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSlot = newValue;
                            });
                          },
                          items: snapshot.data!
                              .map<DropdownMenuItem<String>>((String slot) {
                            return DropdownMenuItem<String>(
                              value: slot,
                              child: Text(slot),
                            );
                          }).toList(),
                        ),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: _sendAppointmentRequest,
                        child: Text('Request Appointment'),
                      ),
                    ],
                  ),
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
