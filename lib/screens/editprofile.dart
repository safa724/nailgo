import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emiratesController = TextEditingController();
  String userName = '';
  String userEmail = '';
  bool isLoggedIn = false;
  List<String> cities = [];
  String? selectedCity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchCities().then((value) {
      setState(() {
        cities = value;

        selectedCity = null;
      });
    }).catchError((error) {
      print('Error fetching cities: $error');
    });
  }

  void _selectCity(String? cityName) {
    if (cityName != null) {
      setState(() {
        cityController.text = cityName;
      });
    }
  }

  void _selectEmirates(String? emiratesName) {
    if (emiratesName != null) {
      setState(() {
        emiratesController.text = emiratesName;
      });
    }
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        userName = prefs.getString('userName') ?? '';
        userEmail = prefs.getString('userEmail') ?? '';

        firstNameController.text = userName;
        emailController.text = userEmail;
      } else {
        addressController.text = 'noaddress'.tr();
      }
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();

    emailController.dispose();
    phoneNumberController.dispose();
    cityController.dispose();
    addressController.dispose();
    emiratesController.dispose();
    super.dispose();
  }

  String? selectedPaymentOption;
  String errorMessage = '';

  Future<List<String>> fetchCities() async {
    try {
      final response = await http.get(Uri.http('nailgo.ae', '/api/v2/cities'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('data')) {
          List<String> cities = [];
          final cityList = data['data'] as List;
          cityList.forEach((city) {
            cities.add(city['name']);
          });
          return cities;
        } else {
          throw Exception('Cities not found in API response');
        }
      } else {
        throw Exception('Failed to fetch cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }

  List<String> paymentOptions = [
    'cashondelivery'.tr(),
  ];
  List<String> emirates = [
    'abudhabi'.tr(),
    'dubai'.tr(),
    'sharjah'.tr(),
    'ajman'.tr(),
    'ummal'.tr(),
    'rasal'.tr(),
    'fujairah'.tr(),
  ];
  String? selectedEmirates;

  Future<void> _saveProfile() async {
    print(firstNameController.text);
    print(emailController.text);
    print(phoneNumberController.text);
    print(cityController.text);
    print(addressController.text);
    print(emiratesController.text);
    if (firstNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        addressController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('error'.tr()),
          content: Text('please'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ok'.tr()),
            ),
          ],
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';
      String accessToken = prefs.getString('accessToken') ?? '';
      final url = Uri.parse('http://nailgo.ae/api/v2/profile/update');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'id': userId,
          'name': firstNameController.text,
          'phone': phoneNumberController.text,
          'email': emailController.text,
          'city': cityController.text,
          'emirates': emiratesController.text,
        }),
      );
      if (response.statusCode == 200) {
        print(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('success'.tr()),
            content: Text('profilesuccess'.tr()),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'ok'.tr(),
                  style: TextStyle(color: Color.fromARGB(255, 185, 92, 4)),
                ),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('error'.tr()),
            content: Text('failedprofile'.tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ok'.tr()),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('error'.tr()),
          content: Text('erroroccured'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ok'.tr()),
            ),
          ],
        ),
      );
    }
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 5),
                  Text(
                    'edit'.tr(),
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('fn'.tr()),
                          SizedBox(height: 5),
                          Container(
                            width: 325,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: TextField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('email'.tr()),
                      SizedBox(height: 5),
                      Container(
                        width: 362,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Phone Number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('phone'.tr()),
                      SizedBox(height: 5),
                      Container(
                        width: 362,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextField(
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  //  City
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('city'.tr()),
                      SizedBox(height: 5),
                      Container(
                        width: 362,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: DropdownButtonFormField<String>(
                            value: selectedCity,
                            decoration: InputDecoration(
                              hintText: 'choosecity'.tr(),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                selectedCity = newValue; // Update selected city
                              });
                            },
                            items: cities.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Address
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('address'.tr()),
                      SizedBox(height: 5),
                      Container(
                        width: 362,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Emirates
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('emira'.tr()),
                      SizedBox(height: 5),
                      Container(
                        width: 362,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 5),
                          child: DropdownButtonFormField<String>(
                            value: selectedEmirates,
                            decoration: InputDecoration(
                              hintText: 'chooseemirates'.tr(),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                selectedEmirates =
                                    newValue; // Update selected emirate
                              });
                            },
                            items: emirates.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  SizedBox(height: 30),

                  InkWell(
                    onTap: () {
                      _saveProfile();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 50,
                        width: 400,
                        child: Center(
                          child: Text(
                            'save'.tr(),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 185, 92, 4),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 185, 92, 4),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
