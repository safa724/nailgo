import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  Future<void> printSharedPreferences() async {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Retrieve and print stored values
    String? accessToken = prefs.getString('accessToken');
    String? userId = prefs.getString('userId');
    String? userName = prefs.getString('userName');
    String? userEmail = prefs.getString('userEmail');
    String? userAvatar = prefs.getString('userAvatar');

    print("Access Token: $accessToken");
    print("User ID: $userId");
    print("User Name: $userName");
    print("User Email: $userEmail");
    print("User Avatar: $userAvatar");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await printSharedPreferences(); // Call the function to print data
          },
          child: Text("Print Stored Preferences"),
        ),
      ),
    );
  }
}
