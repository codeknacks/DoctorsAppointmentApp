import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorChatScreen extends StatefulWidget {
  final String patientName;
  final String patientId; // Receive the patientId
  final String appointmentId;

  DoctorChatScreen(
      {required this.patientName,
      required this.patientId,
      required this.appointmentId});

  @override
  _DoctorChatScreenState createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late String doctorId;
  String? patientImageUrl;

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;
    if (user != null) {
      doctorId = user.uid;
    }
    _getPatientData();
  }

  void _getPatientData() async {
    try {
      DocumentSnapshot patientDoc =
          await _firestore.collection('patients').doc(widget.patientId).get();
      if (patientDoc.exists) {
        setState(() {
          patientImageUrl = patientDoc['profile_image'];
        });
      }
    } catch (e) {
      print('Error fetching patient data: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('chats').add({
        'doctorId': doctorId,
        'patientId': widget.patientId,
        'appointmentId': widget.appointmentId,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': 'doctor',
        'patientName': widget.patientName,
      });
      await _firestore
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _confirmDeleteMessage(String messageId, String sender) {
    if (sender != 'doctor') {
      // If the sender is not the doctor, do not allow deletion
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cannot Delete Message'),
            content: Text('You can only delete your own messages.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // If the sender is the doctor, allow deletion
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Message'),
            content: Text('Are you sure you want to delete this message?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  _deleteMessage(messageId);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _deleteMessage(String messageId) async {
    try {
      await _firestore.collection('chats').doc(messageId).delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (patientImageUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(patientImageUrl!),
              ),
            SizedBox(width: 8.0),
            Text(widget.patientName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('doctorId', isEqualTo: doctorId)
                  .where('patientId', isEqualTo: widget.patientId)
                  .where('appointmentId', isEqualTo: widget.appointmentId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message =
                        messages[index].data() as Map<String, dynamic>;
                    var timestamp = message['timestamp'] != null
                        ? (message['timestamp'] as Timestamp).toDate()
                        : null;
                    return ListTile(
                      title: GestureDetector(
                        onLongPress: () => _confirmDeleteMessage(
                            messages[index].id, message['sender']),
                        child: Align(
                          alignment: message['sender'] == 'doctor'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: message['sender'] == 'doctor'
                                  ? Colors.blue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: message['sender'] == 'doctor'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                if (timestamp != null)
                                  Text(
                                    '${timestamp.hour}:${timestamp.minute}, ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
