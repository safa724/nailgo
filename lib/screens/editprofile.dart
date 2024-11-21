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

  String? selectedEmirates;
  List<String> paymentOptions = ['cashondelivery'.tr()];
  List<String> emirates = [
    'abudhabi'.tr(),
    'dubai'.tr(),
    'sharjah'.tr(),
    'ajman'.tr(),
    'ummal'.tr(),
    'rasal'.tr(),
    'fujairah'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchCities().then((value) {
      setState(() {
        cities = value;
      });
    }).catchError((error) {
      print('Error fetching cities: $error');
    });
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

  Future<List<String>> fetchCities() async {
    try {
      final response = await http.get(Uri.http('nailgo.ae', '/api/v2/cities'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('data')) {
          return (data['data'] as List).map((city) => city['name'] as String).toList();
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

  Future<void> _saveProfile() async {
    if (firstNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        addressController.text.isEmpty) {
      _showDialog('error'.tr(), 'please'.tr());
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
        _showDialog('success'.tr(), 'profilesuccess'.tr());
      } else {
        _showDialog('error'.tr(), 'failedprofile'.tr());
      }
    } catch (e) {
      _showDialog('error'.tr(), 'erroroccured'.tr());
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
                  _buildHeader('edit'.tr()),
                  _buildTextField('fn'.tr(), firstNameController),
                  _buildTextField('email'.tr(), emailController),
                  _buildTextField('phone'.tr(), phoneNumberController),
                  _buildDropdown('city'.tr(), cities, selectedCity, cityController),
                  _buildTextField('address'.tr(), addressController),
                  _buildDropdown('emira'.tr(), emirates, selectedEmirates, emiratesController),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 185, 92, 4),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Column(
      children: [
        SizedBox(height: 5),
        Text(text, style: TextStyle(fontSize: 25)),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label.tr(),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedItem, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedItem,
          decoration: InputDecoration(
            hintText: label.tr(),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
          onChanged: (newValue) {
            setState(() {
              selectedItem = newValue;
              controller.text = newValue ?? '';
            });
          },
          items: items.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: _saveProfile,
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
    );
  }
}
