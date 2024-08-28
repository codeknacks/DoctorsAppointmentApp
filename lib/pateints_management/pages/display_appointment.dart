import 'package:doctor_appointment_app/pateints_management/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookedAppointmentsPage extends StatelessWidget {
  const BookedAppointmentsPage({Key? key}) : super(key: key);

  void _startChat(BuildContext context, String doctorId, String appointmentId,
      String patientId) async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

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

  void _showReviewDialog(BuildContext context, String appointmentId, String doctorId, String patientId) async {
    final _formKey = GlobalKey<FormState>();
    double? _rating;
    String _description = '';
    DocumentSnapshot? existingReview;

    try {
      var reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('appointmentId', isEqualTo: appointmentId)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        existingReview = reviewsSnapshot.docs.first;
        _rating = existingReview['rating'];
        _description = existingReview['description'];
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(existingReview == null ? 'Leave a Review' : 'Edit Your Review'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: _rating ?? 0,
                  minRating: 1,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) => _rating = rating,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 3,
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) => _description = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  if (existingReview == null) {
                    _submitReview(appointmentId, _rating!, _description, doctorId, patientId);
                  } else {
                    _updateReview(existingReview.id, _rating!, _description);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(existingReview == null ? 'Submit' : 'Update'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch review: $e')),
      );
    }
  }

  void _submitReview(String appointmentId, double rating, String description, String doctorId, String patientId) {
    FirebaseFirestore.instance.collection('reviews').add({
      'appointmentId': appointmentId,
      'rating': rating,
      'description': description,
      'doctorId': doctorId,
      'patientId': patientId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _updateReview(String reviewId, double rating, String description) {
    FirebaseFirestore.instance.collection('reviews').doc(reviewId).update({
      'rating': rating,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Appointments'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: user?.uid)
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
              String status = appointment['status'];
              String patientId = appointment['patientId'];
              String doctorId = appointment['doctorId'];

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
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                      if (status == 'accepted')
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _startChat(
                                  context,
                                  doctorId,
                                  appointment.id,
                                  patientId),
                              child: const Text('Chat with Doctor'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _showReviewDialog(context, appointment.id, doctorId, patientId),
                              child: const Text('Leave or Edit Review'),
                            ),
                          ],
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