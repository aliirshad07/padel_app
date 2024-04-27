import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:padel_app/screens/chat_screen.dart';
import 'package:padel_app/screens/groups_screen.dart';
import 'package:padel_app/services/firebase_services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUsersData();
    print(services.users);
  }

  Future<void> _loadUsersData() async {
    final userData = await services.getUsersData();
    setState(() {
      services.users = userData;
    });
  }

  TextEditingController _controller = TextEditingController();
  final services = FirebaseServices();
  String text = '';
  List<Map<String, dynamic>> selectedUsers = [];
  TextEditingController _groupNameController = TextEditingController();

  void addUser(String name, String phone, String userId) {
    // Check if the user with the given userId already exists in selectedUsers
    bool userExists = selectedUsers.any((user) => user['uid'] == userId);

    // If the user doesn't exist, add them to selectedUsers
    if (!userExists) {
      selectedUsers.add({
        'name': name,
        'phone': phone,
        'uid': userId,
      });
      print('User added successfully.');
      print("user after adding: $selectedUsers");
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("User already exists\nDo you want to remove it"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    selectedUsers.removeWhere(
                        (user) => user['uid'] == userId); // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: Text('Remove'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog and pass selectedUsers
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          });
      print('User with ID $userId already exists.');
      print("user after removing: $selectedUsers");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          "Chats",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              print("clicked");
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select to Add'),
                      content: Container(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: services.users.length,
                          itemBuilder: (context, index) {
                            final entry =
                                services.users.entries.elementAt(index);
                            final userData = entry.value;
                            final userId = userData['uid'] as String;
                            final name = userData['name'] as String;
                            final phone = userData['phone'] as String;
                            final isSelected = selectedUsers
                                .any((user) => user['uid'] == userId);

                            return InkWell(
                              onTap: () {
                                addUser(name, phone, userId);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name),
                                  SizedBox(height: 8),
                                  Text(phone),
                                  Divider(), // Add a divider between each item
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Close the dialog and pass selectedUsers
                            print("user are: $selectedUsers");
                            if (selectedUsers.isNotEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Enter Group Name'),
                                      content: TextField(
                                        controller: _groupNameController,
                                        decoration: InputDecoration(
                                            hintText: 'Group Name'),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            selectedUsers.clear();
                                            _groupNameController.clear();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Call a function to create the group with the entered name
                                            String groupName =
                                                _groupNameController.text
                                                    .trim();
                                            // Validate the group name before proceeding
                                            if (groupName.isNotEmpty) {
                                              // Call a function to create the group
                                              _groupNameController.clear();
                                              services.createGroup(groupName,
                                                  selectedUsers, context);
                                              Get.back();
                                              Get.back();
                                              selectedUsers.clear();

                                              // _createGroup(groupName);
                                            } else {
                                              // Show a snackbar indicating that the group name is empty
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Please enter a group name'),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text('Create Group'),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },
                          child: Text('Done'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            selectedUsers.clear();
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  });
            },
            child: Text(
              "Create Group",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (value) {
                  // Handle text field changes
                  setState(() {});
                },
                keyboardType: TextInputType.number,
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Enter your search term...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      width: 10.0, // Adjust the border width here
                      color: Colors.black, // Adjust the border color here
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                alignment: Alignment.topCenter,
                height: MediaQuery.of(context).size.height*0.65,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: (() {
                  // Filter users based on search text
                  final filteredUsers = services.users.values.where((userData) {
                    final searchText = _controller.text;
                    return userData['phone'].contains(searchText);
                  }).toList();
        
                  // Return the ListView.builder directly based on the search text
                  if (_controller.text.isEmpty) {
                    return services.users.isEmpty?
        
                        Center(
                          child: CircularProgressIndicator(),
                        ): ListView.builder(
                      itemCount: services.users.length,
                      itemBuilder: (context, index) {
                        final userData = services.users.values.elementAt(index);
                        final number = userData['phone'];
                        final docId = userData['uid'];
                        final name = userData['name'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Card(
                            color: Colors.grey.shade200,
                            child: ListTile(
                              onTap: () {
                                Get.to(() => ChatScreen(number: number, docId: docId));
                              },
                              title: Text(name),
                              subtitle: Text(number),
                              // Add onTap handler here if needed
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return filteredUsers.isEmpty
                        ? Center(
                      child: Text('No users found'),
                    )
                        : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final userData = filteredUsers[index];
                        return ListTile(
                          onTap: () {
                            Get.to(() => ChatScreen(
                                number: userData['phone'], docId: userData['uid']));
                          },
                          title: Text(
                            userData['name'],
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            userData['phone'],
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          trailing: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    );
                  }
                })(),
              )
        
            ],
          ),
        ),
      ),
    );
  }
}
// ListView.builder(
// itemCount: services.users.length,
// itemBuilder: (context, index) {
// final userData = services.users.values.elementAt(index);
// final number = userData['phone'];
// final docId = userData['uid'];
// final name = userData['name'];
// return Padding(
// padding: const EdgeInsets.all(8.0),
// child: Card(
// color: Colors.grey.shade200,
// child: ListTile(
// onTap: () {
// Get.to(() => ChatScreen(
// number: number, docId: docId));
// },
// title: Text(name),
// subtitle: Text(number),
// // Add onTap handler here if needed
// ),
// ),
// );
// },
// )