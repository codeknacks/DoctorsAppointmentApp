import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final String name;
  final int age;
  final int mobileNumber;
  final String appointmentId;  // Add the appointment ID to update the status
  final String status;  // Add the status field

  AppointmentDetailsPage({
    required this.name,
    required this.age,
    required this.mobileNumber,
    required this.appointmentId,
    required this.status,  // Add this parameter
  });

  // Method to update the status
  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': newStatus});

      // Optionally, show a success message
      // You may need a context to show a Snackbar
    } catch (e) {
      // Handle any errors here
      print('Failed to update status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                Text(
                  "Name: $name",
                  style: const TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  "Age: $age",
                  style: const TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  "Mobile Number: $mobileNumber",
                  style: const TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  "Status: $status",
                  style: TextStyle(
                    fontSize: 18,
                    color: status == 'accepted'
                        ? Colors.green
                        : status == 'declined'
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: status == 'pending'
                          ? () {
                              _updateStatus('accepted');
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                      ),
                    ),
                    ElevatedButton(
                      onPressed: status == 'pending'
                          ? () {
                              _updateStatus('declined');
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text('Decline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Background color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
