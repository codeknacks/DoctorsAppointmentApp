import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_appointment_app/pateints_management/pages/chat_page.dart';

class ChatOverviewPage extends StatelessWidget {
  const ChatOverviewPage({Key? key}) : super(key: key);

  void _startChat(BuildContext context, String doctorId, String appointmentId, String patientId) async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();

      if (doctorSnapshot.exists) {
        String doctorName = doctorSnapshot['name'];
        String profilePicUrl = doctorSnapshot['profilePicUrl'];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Overview'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: user?.uid) // Filter by logged-in user's patientId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var appointment = snapshot.data!.docs[index];
              String doctorId = appointment['doctorId'];
              String patientId = appointment['patientId'];

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
                      Text("Age: ${appointment['age']}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Mobile: ${appointment['mobileNumber']}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Appointment Date: ${appointment['appointmentDate']}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Slot: ${appointment['appointmentSlot']}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _startChat(context, doctorId, appointment.id, patientId),
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
