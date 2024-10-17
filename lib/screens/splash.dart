import 'package:flutter/material.dart';
import 'package:nailgonew/screens/home.dart';
import 'package:nailgonew/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () async {
      bool isLoggedIn = await checkLoggedInStatus();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? Home() : LoginPage(),
        ),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
            height: 300,
            width: 300,
            child: Image.asset('assets/splahs_logo.png')),
      ),
    );
  }

  Future<bool> checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
