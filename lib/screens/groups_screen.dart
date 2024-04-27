  import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:padel_app/screens/group_chat_screen.dart';

class GroupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (BuildContext context, var snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
// Display a loading indicator while waiting for data
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
// If an error occurs, display an error message
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }else if(snapshot.isNull){
            return Center(
              child: Text(
                "No groups created yet"
              ),
            );

          } else {
// If data is available, display the group names
            final List<DocumentSnapshot> groups = snapshot.data!.docs;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final groupName = groups[index].get('groupName');
                final docId = groups[index].get('groupId');
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.grey.shade200,
                    child: ListTile(
                      onTap: (){
                        Get.to(()=> GroupChatScreen(name: groupName, docId: docId));
                      },
                      title: Text(groupName),
                  // Add onTap handler here if needed
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}