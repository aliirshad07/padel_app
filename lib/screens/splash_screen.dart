import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_app/screens/bottom_nav_bar.dart';
import 'package:padel_app/screens/search_screen.dart';
import 'package:padel_app/services/firebase_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final services = FirebaseServices();

  @override
  void initState() {
    // TODO: implement initState
    // services.getUsersData();
    super.initState();
    Timer(
      const Duration(seconds: 5),
          (){
        Get.offAll(()=> BottomNavBar());
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Image.asset('assets/chatss.png'),
      ),
    );
  }
}
