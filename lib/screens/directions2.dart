import 'package:flutter/material.dart';
import 'package:nailgonew/screens/camera2.dart';



class Direction2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Please place your thumb on a plain background while hiding the other fingers, like this, during scanning ',
                style: TextStyle( color: Colors.black,fontSize: 12),
              ),
            ),
            SizedBox(height: 20),
            Container(height: 230, width: 230, 
            child:  ClipRect(
           
              child: Image.asset('assets/Manicured clubbed thumb.jpg'))),
            SizedBox(height:20),
           Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'And take picture with a shortest distance for getting accuracy in measurement',
                style: TextStyle( color: Colors.black,fontSize: 12),
              ),
            ),
            SizedBox(height: 60),
            BrownButton(
              label: 'CONTINUE',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Camera2Screen())
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BrownButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  BrownButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 250,
        height: 50,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 185, 92, 4),
          
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
