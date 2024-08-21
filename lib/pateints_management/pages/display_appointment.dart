import 'package:doctor_appointment_app/pateints_management/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookedAppointmentsPage extends StatelessWidget {
  const BookedAppointmentsPage({Key? key}) : super(key: key);

  void _startChat(BuildContext context, String doctorId, String appointmentId, String patientId) async {
  // Fetch the doctor's details from the 'doctors' collection
  DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
      .collection('doctors')
      .doc(doctorId)
      .get();

  if (doctorSnapshot.exists) {
    String doctorName = doctorSnapshot['name'];
    String profilePicUrl = doctorSnapshot['profilePicUrl'];

    // Navigate to the ChatScreen with the doctor's details and patientId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          doctorId: doctorId,
          doctorName: doctorName,
          profilePicUrl: profilePicUrl,
          appointmentId: appointmentId,
          patientId: patientId,
        ),
      ),
    );
  } else {
    // Handle the case where the doctor doesn't exist
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Doctor not found.')),
    );
  }
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Booked Appointments'),
      automaticallyImplyLeading: false,
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No appointments found.'));
        }

        // Map the snapshot data to a list of appointment cards
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var appointment = snapshot.data!.docs[index];
            String status = appointment['status'];
            String patientId = appointment['patientId']; // Assuming patientId is stored in the appointment document

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${appointment['name']}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Age: ${appointment['age']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mobile: ${appointment['mobileNumber']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Appointment Date: ${appointment['appointmentDate']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Slot: ${appointment['appointmentSlot']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Status: $status",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (status == 'accepted') // Show chat button only if status is accepted
                      ElevatedButton(
                        onPressed: () => _startChat(context, appointment['doctorId'], appointment.id, patientId),
                        child: const Text('Chat with Doctor'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

  }


