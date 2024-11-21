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
 
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emiratesController = TextEditingController();
   bool isLoading = false; 
  String userName = '';
  String userEmail = '';
  bool isLoggedIn = false;
  List<String> cities = [];
  String? selectedCity;
List<Map<String, String>> paymentOptions = [];  // Correctly define as List of Maps
String? selectedPaymentOptionKey;


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
  fetchPaymentTypes(); // Fetch payment types on init

  }
  



Future<void> fetchPaymentTypes() async {
  try {
    final response = await http.get(Uri.http('nailgo.ae', '/api/v2/payment-types'));
    print('API Response: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      
      setState(() {
        // Make sure to set the state with the correct data structure
        paymentOptions = jsonData.map<Map<String, String>>((paymentType) {
          return {
            'payment_type_key': paymentType['payment_type_key'],
            'name': paymentType['name'],
            'image': paymentType['image'],
          };
        }).toList();
      });
    } else {
      print('Failed to fetch payment types: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching payment types: $e');
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
   
    addressController.dispose();
    emiratesController.dispose();
    super.dispose();
  }



 
  String errorMessage = '';

 

void _createOrder() async {
  // Check if all fields are filled
  if (firstNameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneNumberController.text.isEmpty ||
      addressController.text.isEmpty ||
      selectedCity == null ||
      selectedEmirates == null ||
      selectedPaymentOptionKey == null) {
    // Show an alert dialog if fields are not filled
    _showFillFieldsDialog();
  } else {
    setState(() {
      isLoading = true; // Show the loader
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';
    String userId = prefs.getString('userId') ?? '';

    if (accessToken.isNotEmpty && userId.isNotEmpty) {
      Map<String, dynamic> requestBody = {
        "owner_id": userId,
        "user_id": userId,
        "payment_type": selectedPaymentOptionKey ?? "cash_on_delivery"
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
          print("Order created successfully!");

          // Print all values
          print("First Name: ${firstNameController.text}");
          print("Email: ${emailController.text}");
          print("Phone Number: ${phoneNumberController.text}");
          print("Address: ${addressController.text}");
          print("City: $selectedCity");
          print("Emirates: $selectedEmirates");
          print("Payment Option: $selectedPaymentOptionKey");
          print("Response Body: ${response.body}");

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
      } finally {
        setState(() {
          isLoading = false; // Hide the loader
        });
      }
    } else {
      setState(() {
        errorMessage = 'Access token or user ID not available';
        isLoading = false; // Hide the loader
      });
    }
  }
}


void _showFillFieldsDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.yellow, size: 40),
            SizedBox(width: 10),
          
          ],
        ),
        content: Text(
          'It looks like some fields are missing. Please fill all the required fields before proceeding.',
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.orange)),
          ),
        ],
      );
    },
  );
}



Future<List<String>> fetchCities() async {
  try {
    final response = await http.get(Uri.http('nailgo.ae', '/api/v2/cities'));
    print('API Response: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is Map && jsonData.containsKey('data')) {
        return List<String>.from(jsonData['data'].map((city) => city['name']));
      } else {
        throw Exception('Invalid API response: "data" key not found');
      }
    } else {
      throw Exception('Failed to fetch cities: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching cities: $e');
    return []; // Return an empty list to handle errors gracefully
  }
}

 List<String> emirates = [
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al-Quwain',
    'Ras Al Khaimah',
    'Fujairah',
  ];
  String? selectedEmirates = 'Dubai';  // Default value

  void _handleSubmit() {
    print("Selected Emirates: $selectedEmirates");  // Check selected value
    // Add other submission logic here
  }


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
                  'Check Out',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(height: 40),

                // First Name
                _buildInputField(
                  label: 'fn'.tr(),
                  controller: firstNameController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // Email
                _buildInputField(
                  label: 'email'.tr(),
                  controller: emailController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // Phone Number
                _buildInputField(
                  label: 'phone'.tr(),
                  controller: phoneNumberController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // City Dropdown
                _buildInputField(
                  label: 'city'.tr(),
                  isDropdown: true,
                  dropdownValue: selectedCity,
                  items: cities,
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                ),
                SizedBox(height: 10),

                // Address
                _buildInputField(
                  label: 'address'.tr(),
                  controller: addressController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // Emirates Dropdown
          
          _buildInputField(
              label: 'Emirates',
              isDropdown: true,
              dropdownValue: selectedEmirates,
              items: emirates,
              onChanged: (value) {
                setState(() {
                  selectedEmirates = value;
                });
              },
            ),

                SizedBox(height: 10),

                // Payment Options Dropdown
              // Payment Options Dropdown
_buildInputField(
  label: 'Payment Option',
  isDropdown: true,
  dropdownValue: selectedPaymentOptionKey,
  items: paymentOptions
      .map((paymentType) => paymentType['name'] ?? '') // Default to empty string if null
      .where((value) => value.isNotEmpty) // Remove any empty values if needed
      .toList(),
  onChanged: (value) {
    setState(() {
      selectedPaymentOptionKey = value!; // Update selected value
    });
  },
  itemImages: paymentOptions
      .map((paymentType) => paymentType['image'] ?? '') // Assuming 'payment_image' holds image path
      .where((image) => image.isNotEmpty) // Remove any empty values if needed
      .toList(),
),


                SizedBox(height: 30),

                // Order Button
                InkWell(
                  onTap: _createOrder,
                  child: Container(
                    height: 50,
                    width: double.infinity,
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
              ],
            ),
          ),
        ),

        // Loader overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildInputField({
  required String label,
  TextEditingController? controller,
  bool isDropdown = false,
  String? dropdownValue,
  List<String>? items,
  ValueChanged<String?>? onChanged,
  List<String>? itemImages, // List of image paths (URLs or assets)
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      SizedBox(height: 5),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: isDropdown
              ? DropdownButtonFormField<String>(
                  value: dropdownValue,
                  decoration: InputDecoration(
                    hintText: 'Choose $label',
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                  items: items?.asMap().map((index, value) {
                    return MapEntry(
                      index,
                      DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            // Check if an image exists for the current item
                            if (itemImages != null && itemImages.length > index && itemImages[index].isNotEmpty) 
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(itemImages[index], width: 30, height: 30),
                              ),
                            // Text is always displayed
                            Text(value),
                          ],
                        ),
                      ),
                    );
                  }).values.toList(),
                )
              : TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
        ),
      ),
    ],
  );
}}