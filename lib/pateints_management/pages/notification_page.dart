import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  final String patientId;

  NotificationsScreen({required this.patientId});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('receiver', isEqualTo: widget.patientId)
        .where('senderType', isEqualTo: 'doctor')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void markAsRead(String docId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(docId)
        .update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('No new messages from doctors.'));
          }

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return NotificationCard(
                doctorName: data['senderName'],
                message: data['message'],
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                isRead: data['isRead'] ?? false,
                onTap: () {
                  markAsRead(doc.id);
                  // Navigate to chat screen
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String doctorName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final VoidCallback onTap;

  NotificationCard({
    required this.doctorName,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isRead ? Colors.white : Colors.blue[50],
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(doctorName[0]),
        ),
        title: Text('Dr. $doctorName'),
        subtitle: Text(
          message.length > 30 ? '${message.substring(0, 30)}...' : message,
        ),
        trailing: Text(
          '${timestamp.hour}:${timestamp.minute}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}
