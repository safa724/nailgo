import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nailgonew/screens/home.dart';

class Success extends StatefulWidget {
  const Success({super.key});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: () async {
        // Navigate to the Home Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/icons-26.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'successdialogue'.tr(),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 10),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => Home()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 185, 92, 4),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: 50,
                    width: 220,
                    child: Center(
                        child: Text(
                      'continueshopping'.tr(),
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
