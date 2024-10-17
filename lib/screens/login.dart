import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/home.dart';
import 'package:nailgonew/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    final String apiUrl = "http://nailgo.ae/api/v2/auth/login";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
      },
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
        "identity_matrix": "ec669dad-9136-439d-b8f4-80298e7e6f37",
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> responseData = json.decode(response.body);
      String accessToken = responseData['access_token'];
      String userId = responseData['user']['id'].toString();
      String userName = responseData['user']['name'];
      String userEmail = responseData['user']['email'];
      //String userPhone = responseData['user']['phone'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('userId', userId);
      prefs.setString('userName', userName);
      prefs.setString('userEmail', userEmail);
      prefs.setString('accessToken', accessToken);
      // prefs.setString('userPhone', userPhone);
      // Successful login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed. Please check your credentials."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();

        return true;
      },
      child: Scaffold(
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Welcome',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 201, 152, 79),
                            fontSize: 23,
                            fontFamily: 'Brown Sugar'),
                      ),
                      SizedBox(
                        height: 160,
                      ),
                      Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 201, 152, 79),
                            fontSize: 23,
                            fontFamily: 'Brown Sugar'),
                      ),
                      SizedBox(height: 25),
                      TextField(
                        cursorColor: Colors.black,
                        controller: emailController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: ' Email or Phone number',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 15.0), //
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        cursorColor: Colors.black,
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: ' Password',

                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 15.0), //
                        ),
                      ),
                      SizedBox(height: 70),
                      Container(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            loginUser(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(218, 212, 90, 19),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Brown Sugar'),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Center(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()),
                                );
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 185, 92, 4),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 200)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
