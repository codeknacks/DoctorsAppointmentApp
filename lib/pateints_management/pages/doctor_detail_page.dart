import 'package:doctor_appointment_app/pateints_management/components/nav_bar.dart';
import 'package:doctor_appointment_app/pateints_management/pages/chat_page.dart';
import 'package:doctor_appointment_app/pateints_management/pages/display_appointment.dart';
import 'package:doctor_appointment_app/pateints_management/pages/profile_pateint.dart';
import 'package:doctor_appointment_app/pateints_management/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class DoctorDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot doctor;

  DoctorDetailsPage({required this.doctor});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  int _selectedIndex = 0;
  String? selectedSlot;
  DateTime? selectedDate;

  // Method to show the dialog box and handle input
  Future<void> _showInputDialog() async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final mobileNumberController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        DateTime? localSelectedDate = selectedDate;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      controller: mobileNumberController,
                      decoration: InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextButton(
                      child: Text('Select Date'),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: localSelectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            localSelectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    Text(
                      localSelectedDate != null
                          ? DateFormat('y MMMM d').format(localSelectedDate!)
                          : 'No date selected',
                      style: TextStyle(fontSize: 16),
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
                    if (localSelectedDate == null || selectedSlot == null) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Please select an appointment date and time slot'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      });
                      return;
                    }
                    setState(() {
                      selectedDate = localSelectedDate;
                    });
                    _saveAppointment(
                      nameController.text,
                      int.parse(ageController.text),
                      mobileNumberController.text,
                      selectedDate!,
                      selectedSlot!,
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to save the input values to Firestore
  void _saveAppointment(String name, int age, String mobileNumber,
      DateTime date, String slot) async {
    final DateFormat formatter =
        DateFormat('yyyy-MM-dd'); // Adjust format as needed
    final String formattedDate = formatter.format(date);

    try {
      // Fetch the patient's data from Firestore based on the mobile number
      QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('mobile', isEqualTo: mobileNumber)
          .limit(1)
          .get();

      if (patientSnapshot.docs.isNotEmpty) {
        DocumentSnapshot patientDoc = patientSnapshot.docs.first;
        String patientId = patientDoc['patientId'];
        String deviceToken = patientDoc['deviceToken'];

        // Generate a unique appointment ID using Firestore's document ID
        DocumentReference appointmentRef =
            FirebaseFirestore.instance.collection('appointments').doc();
        String appointmentId = appointmentRef.id;

        // Save the appointment to Firestore with the generated ID
        await appointmentRef.set({
          'appointmentId': appointmentId, // Store the generated appointment ID
          'doctorId': widget.doctor.id,
          'patientId': patientId,
          'name': name,
          'age': age,
          'mobileNumber': mobileNumber,
          'appointmentDate': formattedDate,
          'appointmentSlot': slot,
          'status': 'Pending', // Initial status
          'patientDeviceToken': deviceToken, // Store patient's device token
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the BookedAppointmentsPage where the summary is there
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookedAppointmentsPage(), // Pass the patientId here
        //   ),
        // );
      } else {
        // Show error message if patient not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message in case of failure
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit request: $e'),
      ));
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
                    "Rate Per Hour: ${widget.doctor['ratePerHour']}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Specialization: ${widget.doctor['specialization']}",
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
                      // Iterate over each available slot and create a separate Container for each
                      ...List.generate(widget.doctor['availableSlots'].length,
                          (index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedSlot =
                                  widget.doctor['availableSlots'][index];
                            });
                            _showInputDialog();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selectedSlot ==
                                      widget.doctor['availableSlots'][index]
                                  ? Colors.blue
                                  : Colors.green,
                              border: Border.all(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(widget.doctor['availableSlots'][index]),
                          ),
                        );
                      }),
                    ],
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
