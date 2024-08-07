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
  List<String> slots = [];
  bool isLoading = false;
  final TextEditingController _slotController = TextEditingController();

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
            slots = List<String>.from(data['availableSlots']);
          });
        }
      }
    }
  }

  void _addSlot() {
    if (_slotController.text.isNotEmpty) {
      setState(() {
        slots.add(_slotController.text);
        _slotController.clear();
      });
    }
  }

  void _removeSlot(int index) {
    setState(() {
      slots.removeAt(index);
    });
  }

  Future<void> _saveSlots() async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference doctorRef =
          _firestore.collection('doctors').doc(user.uid);

      await doctorRef.update({
        'availableSlots': slots,
      }).then((_) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Slots saved successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorHomeScreen()),
        );
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save slots: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor Availability Management')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _slotController,
                    decoration: InputDecoration(
                      labelText: 'Enter available slot (e.g., 9 PM - 10 PM)',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _addSlot,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(slots[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeSlot(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveSlots,
                    child: Text('Save Slots'),
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
