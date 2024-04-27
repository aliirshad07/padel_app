import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_app/services/firebase_services.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.name, required this.docId});

  final String name;
  final String docId;
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final services = FirebaseServices();



  final List<Map<String, String>> chatMessages = [
    {'type': 'sender', 'message': 'Hello'},
    {'type': 'receiver', 'message': 'Hi there!'},
    {'type': 'sender', 'message': 'How are you?'},
    {'type': 'receiver', 'message': 'I\'m fine, thank you!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('groups').doc(widget.docId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Start a conversation with ${widget.name}'),
                  Expanded(child: SizedBox()),
                  _buildMessageBox()
                ],
              );
            }
            var data = snapshot.data!.data()!;
            var messages = (data as dynamic)['messages'] ?? [];
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      return _buildMessage(
                          "sender",
                          message['message'],
                          index,
                          snapshot,
                          widget.docId

                      );
                    },
                  ),
                ),
                _buildMessageBox(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessage(String type, String message, int index, var snapshot, String docId) {
    return GestureDetector(
      onLongPress: (){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Message"),
              content: Text("Are you sure you want to delete this message?"),
              actions: [
                TextButton(
                  onPressed: (){
                    // Add delete message logic here
                    services.deleteMessage(index, snapshot, docId, "groups");
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text("Delete"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
      child: Align(
        alignment: type == 'sender' ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: type == 'sender' ? Colors.lightBlueAccent : Colors.blueGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: type == 'sender' ? Radius.circular(20) : Radius.circular(0),
              bottomRight: type == 'sender' ? Radius.circular(0) : Radius.circular(20),
            ),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBox() {
    return TextField(
      controller: _messageController,
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'Type your message here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min, // Reduce Row size
          children: [
            // IconButton(
            //   icon: Icon(Icons.attach_file),
            //   onPressed: () {
            //     // Handle attach file functionality
            //   },
            //   color: Colors.teal,
            // ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Handle sending the message
                _messageController.text.isEmpty?
                Get.snackbar("Empty message", "write a message to send", backgroundColor: Colors.white):
                services.sendMessage(widget.docId, _messageController.text.trim(), "groups");

                // Add your logic to send the message here
                _messageController.clear(); // Clear the text field after sending
              },
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}