import 'package:flutter/material.dart';
import 'package:padel_app/screens/groups_screen.dart';
import 'package:padel_app/screens/search_screen.dart';
import 'package:padel_app/services/firebase_services.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  int selectedIndex=0 ;

  List<Widget> listOfPages = [
    SearchScreen(),
    GroupsScreen()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseServices().getUsersData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listOfPages[selectedIndex],
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (newIndex) {
          setState(() {
            selectedIndex = newIndex;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        currentIndex: selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble_sharp,
            ),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.groups,
            ),
            label: 'Groups',
          ),
        ],
      ),
    );
  }
}
