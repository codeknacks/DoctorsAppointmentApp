import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctor_navigation_bar.dart';
import 'doctor_home_screen.dart';
import 'doctor_profile.dart';
import 'chatlistscreen.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  @override
  _DoctorAvailabilityScreenState createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  int _selectedIndex = 2;
  late String doctorId;
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

  void _fetchExistingSlots() async {
    User? user = _auth.currentUser;

    if (user != null) {
      doctorId = user.uid;
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          ' Availability  ',
          style: TextStyle(color: Colors.white),
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
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _slotController,
                    decoration: InputDecoration(
                      labelText: 'Enter available slot (e.g., 9 PM - 10 PM)',
                      labelStyle: TextStyle(color: Colors.blueGrey[800]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.blueGrey[800]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 2.0,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add, color: Colors.blueGrey[800]),
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
                          elevation: 3.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            title: Text(
                              slots[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeSlot(index),
                            ),
                            tileColor: Colors.blueGrey[50],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ElevatedButton(
                      onPressed: _saveSlots,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 12.0),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Slots',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
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
