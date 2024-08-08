// import 'package:doctor_appointment_app/pateints_management/components/apppointment.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:doctor_appointment_app/pateints_management/pages/appointment_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot doctor;

  DoctorDetailsPage({required this.doctor});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  String? selectedSlot;

  // Method to show the dialog box and handle input
  Future<void> _showInputDialog() async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final MobileNumberController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: MobileNumberController,
                  decoration: InputDecoration(labelText: 'MobileNumber'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Done'),
              onPressed: () {
                // Save the input values to Firestore
                _saveAppointment(
                    nameController.text,
                    int.parse(ageController.text),
                    int.parse(
                      MobileNumberController.text,
                    ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to save the input values to Firestore
void _saveAppointment(String name, int age, int mobileNumber) async {
  try {
    await FirebaseFirestore.instance.collection('appointments').add({
      'doctorId': widget.doctor.id,
      'name': name,
      'age': age,
      'mobileNumber': mobileNumber,
      
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request submitted'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to the AppointmentDetailsPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsPage(
          name: name,
          age: age,
          mobileNumber: mobileNumber,
          
        ),
      ),
    );
  } catch (e) {
    // Show error message in case of failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to submit request: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    List<String> availableSlots =
        List<String>.from(widget.doctor['availableSlots']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctor['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        widget.doctor['profilePicUrl'],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      widget.doctor['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Clinic Address: ${widget.doctor['clinicAddress']}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "ratePerHour: ${widget.doctor['ratePerHour']}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "specialization: ${widget.doctor['specialization']}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Availability:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                      "Monday: ${widget.doctor['availability']['Monday'] ? 'Available' : 'Not Available'}",
                      style: TextStyle(fontSize: 18)),
                  Text(
                      "Tuesday: ${widget.doctor['availability']['Tuesday'] ? 'Available' : 'Not Available'}",
                      style: TextStyle(fontSize: 18)),
                  Text(
                      "Wednesday: ${widget.doctor['availability']['Wednesday'] ? 'Available' : 'Not Available'}",
                      style: TextStyle(fontSize: 18)),
                  Text(
                      "Thursday: ${widget.doctor['availability']['Thursday'] ? 'Available' : 'Not Available'}",
                      style: TextStyle(fontSize: 18)),
                  Text(
                      "Friday: ${widget.doctor['availability']['Friday'] ? 'Available' : 'Not Available'}",
                      style: TextStyle(fontSize: 18)),
                  Text(
                      "Saturday: ${widget.doctor['availability']['Saturday'] ? 'Available' : 'Not Available'}",
                      style: TextStyle(fontSize: 18)),
                  Text(
                      "Sunday: ${widget.doctor['availability']['Sunday'] ? 'Available' : 'Not Available'}",
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      const Text('Available Slots'),
                      const Divider(thickness: 2, color: Colors.black54),
                      InkWell(
                        onTap: () {
                          _showInputDialog();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 3),
                              borderRadius: BorderRadius.circular(3)),
                          child: Text("${widget.doctor['availableSlots']}"),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
