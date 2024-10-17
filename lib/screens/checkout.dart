import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/addresmodel.dart';
import 'package:nailgonew/screens/succsus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOut extends StatefulWidget {
  final Address? selectedAddress;
  final String? phoneNumber;

  CheckOut({this.selectedAddress, this.phoneNumber});
  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
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
      print('$error');
    });
  }

  void _selectCity(String? cityName) {
    if (cityName != null) {
      setState(() {
        cityController.text = cityName;
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
        phoneNumberController.text =
            widget.phoneNumber ?? 'No phone number available';

        if (widget.selectedAddress != null) {
          List<String> addressLines =
              widget.selectedAddress!.address!.split('\n');
          addressController.text = addressLines.join(', ');
        } else {
          addressController.text = 'No address selected';
        }
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

  bool _areAllFieldsFilled() {
    if (firstNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        emiratesController.text.trim().isEmpty ||
        selectedPaymentOption == null ||
        selectedCity == null ||
        selectedEmirates == null) {
      return false;
    }
    return true;
  }

  String? selectedPaymentOption;
  String errorMessage = '';

  void _createOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';
    String userId = prefs.getString('userId') ?? '';

    if (accessToken.isNotEmpty && userId != 0) {
      Map<String, dynamic> requestBody = {
        "owner_id": userId,
        "user_id": userId,
        "payment_type": selectedPaymentOption ?? "cash_on_delivery"
      };

      Uri url = Uri.http('nailgo.ae', '/api/v2/order/store');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      try {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          print(response.body);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Success()));
        } else {
          setState(() {
            errorMessage = 'Failed to create order: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error creating order: $e';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Access token or user ID not available';
      });
    }
  }

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
    'Cash on Delivery',
  ];
  List<String> emirates = [
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al-Quwain',
    'Ras Al Khaimah',
    'Fujairah',
  ];
  String? selectedEmirates;

  void _selectEmirates(String? emiratesName) {
    if (emiratesName != null) {
      setState(() {
        emiratesController.text = emiratesName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 5),
              Text(
                'Check Out',
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
                        width: 360,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 5),
                          child: TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: TextField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
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
                          hintText: 'Choose a city',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (newValue) {
                          print('Selected city: $newValue');
                          setState(() {
                            selectedCity = newValue;
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
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
                          hintText: 'Choose Emirates',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (newValue) {
                          print('Selected emirates: $newValue');
                          setState(() {
                            selectedEmirates = newValue;
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment'),
                  SizedBox(height: 5),
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
                        value: selectedPaymentOption,
                        decoration: InputDecoration(
                          hintText: 'Choose a payment option',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (newValue) {
                          print('Selected payment option: $newValue');
                          setState(() {
                            selectedPaymentOption = newValue!;
                          });
                        },
                        items: paymentOptions.map((String value) {
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

              SizedBox(height: 30),

              InkWell(
                onTap: () {
                  _createOrder();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 50,
                    width: 400,
                    child: Center(
                      child: Text(
                        'ORDER',
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
    );
  }
}
