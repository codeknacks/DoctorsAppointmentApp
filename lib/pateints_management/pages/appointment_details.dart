import 'package:flutter/material.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final String name;
  final int age;
  final int mobileNumber;
  

  AppointmentDetailsPage({
    required this.name,
    required this.age,
    required this.mobileNumber,
    
  });

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
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
