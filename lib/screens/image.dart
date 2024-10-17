import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nailgonew/screens/directions2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageGallery extends StatefulWidget {
  const ImageGallery({Key? key}) : super(key: key);

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('saved_image_path');
    });
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Image.asset('assets/checked.png'),
            Text(
              'Success',
              style: TextStyle(color: Colors.green),
            )
          ]),
          content: Text(
              'Your four-finger measurements have been saved successfully!,Please Capture your thumb!'),
          actions: <Widget>[
            Container(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Direction2(),
                    ),
                  );
                },
                child: Text(
                  'Capture Thumb',
                  style: TextStyle(
                      color: Color.fromARGB(255, 185, 92, 4),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
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
      appBar: AppBar(
        title: Text('Image Gallery'),
      ),
      body: Center(
        child: _imagePath != null
            ? Image.file(
                File(_imagePath!),
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              )
            : Text('No image saved'),
      ),
    );
  }
}
