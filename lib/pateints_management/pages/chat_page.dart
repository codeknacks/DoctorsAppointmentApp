import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String profilePicUrl;
  final String appointmentId;
  final String patientId;

  ChatScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.profilePicUrl,
    required this.appointmentId,
    required this.patientId,
  }) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    print('Sending message: ${_controller.text}');
    print('With appointmentId: $appointmentId, patientId: $patientId');

    // Storing the sent message in the 'chats' collection with patientId, doctorId, and appointmentId
    await FirebaseFirestore.instance.collection('chats').add({
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'message': _controller.text,
      'sender': 'patient',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Clearing controllers after sending the message
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profilePicUrl),
            ),
            const SizedBox(width: 8),
            Text(doctorName),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('appointmentId', isEqualTo: appointmentId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatSnapshot.hasError) {
                  return Center(child: Text('An error occurred: ${chatSnapshot.error}'));
                }

                if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final chatDocs = chatSnapshot.data!.docs;
                print('Messages retrieved: ${chatDocs.length}');

                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    final chatData = chatDocs[index].data() as Map<String, dynamic>;
                    print('Message ${index + 1}: ${chatData['message']} from ${chatData['sender']}');
                    return MessageBubble(
                      message: chatData['message'],
                      isMe: chatData['sender'] != 'doctor',
                      key: ValueKey(chatDocs[index].id),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: isMe
                ? Colors.grey[300]
                : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            message,
            style: TextStyle(
              color: isMe
                  ? Colors.black
                  : Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
