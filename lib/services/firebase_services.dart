

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseServices{


  Map<String, dynamic> users = {};

  Future<Map<String, dynamic>> getUsersData() async {
    Map<String, dynamic> usersData = {};

    try {

      // Get the collection reference
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Get the documents
      QuerySnapshot querySnapshot = await users.get();

      // Iterate through the documents and store the data in the map, excluding the current user
      for (var doc in querySnapshot.docs) {
        usersData[doc.id] = {
          'name': doc['name'],
          'phone': doc['phone'],
          'uid': doc.id,
        };
        print(doc.id);
      }
    } catch (e) {
      print('Error fetching users data: $e');
    }
    users = usersData;
    print(users);

    return users;
  }
  void deleteMessage(int index, var _snapshot, String docId, String collectioName) {
    // Get the current list of messages
    List<dynamic> messages = _snapshot.data!.data()!['messages'] ?? [];

    // Remove the message at the specified index
    messages.removeAt(index);

    // Update the Firestore document with the new list of messages
    FirebaseFirestore.instance
        .collection(collectioName)
        .doc(docId)
        .update({'messages': messages})
        .then((_) {
      print("Message deleted successfully");
    }).catchError((error) {
      print("Error deleting message: $error");
    });
  }


  void sendMessage(String docId, String message, String collection) async {
    try {
      // Get the current time
      DateTime now = DateTime.now();
      Timestamp timestamp = Timestamp.fromDate(now);

      // Create a reference to the chats collection
      CollectionReference chats = FirebaseFirestore.instance.collection(collection);

      // Create a map containing the message and the current time
      Map<String, dynamic> messageData = {
        'message': message,
        'time': timestamp,
      };

      // Update the messages map in the document with the provided docId
      await chats.doc(docId).set({
        'messages': FieldValue.arrayUnion([messageData]),
      }, SetOptions(merge: true));

      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> createGroup(String groupName, List<Map<String, dynamic>> members, BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing the dialog by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(), // Loading indicator
                SizedBox(width: 20),
                Text("Creating group..."), // Text indicating that the group is being created
              ],
            ),
          );
        },
      );
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new document reference for the group
      DocumentReference groupRef = firestore.collection('groups').doc();

      // Set the group data with the provided group name, members, and group ID
      await groupRef.set({
        'groupId': groupRef.id,
        'groupName': groupName,
        'members': members,
      });

      // Show a snackbar indicating that the group was created successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group created successfully: $groupName'),
        ),
      );

      // Log the ID of the newly created group document
      print('New group ID: ${groupRef.id}');
    } catch (error) {
      // Show a snackbar with the error message if there was an error creating the group
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating group: $error'),
        ),
      );
    }
  }

}