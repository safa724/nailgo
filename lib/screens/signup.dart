import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/direction.dart';
import 'package:nailgonew/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

Future<void> signUp(BuildContext context) async {
  final String apiUrl = "http://nailgo.ae/api/v2/auth/signup";

  // Show loading popup immediately
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal while loading
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Signing up..."),
          ],
        ),
      );
    },
  );

  bool isSuccess = false; // Initialize success state

  try {
    // Make sure the dialog is fully shown before making the request
    await Future.delayed(Duration(milliseconds: 300));

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
      },
      body: jsonEncode({
        "name": nameController.text,
        "email_or_phone": emailController.text,
        "password": passwordController.text,
        "register_by": "email",
      }),
    );

    // Parse the response
    final responseData = jsonDecode(response.body);

    // Debug Prints
    print("Full API Response: ${response.body}");
    print("Type of responseData['result']: ${responseData['result'].runtimeType}");
    print("responseData['result']: ${responseData['result']}");

    // Checking response status and success message
    if (response.statusCode == 200 && responseData['result'] == true) {
      final message = responseData['message'].toString().toLowerCase();

      // Consider "signup" or "login" both as a success
      if (message.contains("successfully logged in") || message.contains("signup successful")) {
        print("Signup/Login Success: ${response.body}");
        isSuccess = true; // Indicate successful signup/login

        // Save user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        prefs.setString('accessToken', responseData['access_token'] ?? "");
        prefs.setString('userId', responseData['user']['id'].toString() ?? "");
        prefs.setString('userName', responseData['user']['name'] ?? "");
        prefs.setString('userEmail', responseData['user']['email'] ?? "");
        prefs.setString('userAvatar', responseData['user']['avatar_original'] ?? "");
      } else {
        print("Unexpected success message: $message");
        isSuccess = false;
      }
    } else {
      isSuccess = false;
      print("Signup Error Response: ${response.body}");
    }

    // Close the loading popup if still mounted
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Show success or error message
    await _showPopupMessage(context, 
      isSuccess ? "Signup successful!" : responseData['message'], 
      isSuccess: isSuccess);

    // Show additional popup only if signup was successful
    if (isSuccess) {
      _showMeasurementPopup(context);
    }
  } catch (e) {
    // Close the loading popup in case of error
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    print("Exception Error: $e");

    // Show error message
    await _showPopupMessage(context, "An error occurred during signup.", isSuccess: false);
  }
}

// Popup Message Method
Future<void> _showPopupMessage(BuildContext context, String message, {bool isSuccess = false}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          isSuccess ? "Success" : "Error",
          style: TextStyle(
            color: isSuccess ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}


  void _showMeasurementPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          title: Text(
            'Measure Your Finger',
            style: TextStyle(color: Color.fromARGB(255, 185, 92, 4)),
          ),
          content: Text(
              "To provide you with the best fit for your nails, we need to take measurements of your fingers using the camera."),
          actions: <Widget>[
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color.fromARGB(255, 185, 92, 4),
                ),
                height: 50,
                width: 230,
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoadingPage()),
                      );
                    },
                    child: Text(
                      'Take Finger Measurements',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/nail_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 190,
                    ),
                    Text(
                      "Sign Up Now",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 201, 152, 79),
                          fontSize: 23,
                          fontFamily: 'Brown Sugar'),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      cursorColor: Colors.black,
                      controller: nameController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelText: 'Name',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      cursorColor: Colors.black,
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () async {
                          signUp(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 209, 109, 27),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Brown Sugar'),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Already have an account?",
                            style: TextStyle(),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 185, 92, 4),
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 220,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
