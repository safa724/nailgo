import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/data_model/product_mini_response.dart';
import 'package:nailgonew/screens/addressno.dart';
import 'package:nailgonew/screens/editprofile.dart';
import 'package:nailgonew/screens/myorder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<Product> products = [];
  bool isLoggedIn = false;
  String userName = '';
  String userEmail = '';
  int orderCount = 0;
  int cartCount = 0;
  int wishlistCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchCounts();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final url = Uri.parse('http://nailgo.ae/api/v2/profile/get');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userName = data['message']['name'];
        userEmail = data['message']['email'];
      });
    } else {}
  }

  Future<void> fetchCounts() async {
    final url = Uri.parse('http://nailgo.ae/api/v2/profile/count');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        orderCount = data['ordercount'];
        cartCount = data['cartcount'];
        wishlistCount = data['wishlistcount'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkLoginStatus() async {
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        // userName = prefs.getString('userName') ?? '';
        // userEmail = prefs.getString('userEmail') ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchProfile();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'account'.tr(),
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 185, 92, 4),
                strokeWidth: 1,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      userEmail,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$cartCount',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              'inurcart'.tr(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              '$wishlistCount',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              'inurwish'.tr(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey),
                            )
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              '$orderCount',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              'order'.tr(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyOrder()));
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 214, 214, 214),
                              radius: 25,
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 29,
                                color: Colors.brown,
                              ),
                            ),
                            Text(
                              'orders'.tr(),
                              style: TextStyle(
                                  fontSize: 15, fontFamily: 'Montserrat'),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile()));
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 214, 214, 214),
                              radius: 25,
                              child: Icon(
                                Icons.person_2,
                                size: 29,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'profile'.tr(),
                              style: TextStyle(
                                  fontSize: 15, fontFamily: 'Montserrat'),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddressPage1()));
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 214, 214, 214),
                              radius: 25,
                              child: Icon(Icons.location_pin,
                                  size: 29,
                                  color: Color.fromARGB(255, 185, 92, 4)),
                            ),
                            Text(
                              'address'.tr(),
                              style: TextStyle(
                                  fontSize: 15, fontFamily: 'Montserrat'),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyOrder()));
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'assets/pur.png',
                          ),
                          radius: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'pur'.tr(),
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
    );
  }
}
