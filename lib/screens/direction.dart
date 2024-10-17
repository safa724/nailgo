import 'package:flutter/material.dart';
import 'package:nailgonew/screens/camera.dart';




class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Please place your four fingers on a plane background like this while scanning',
                  style: TextStyle(color: Colors.black,fontSize: 15),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(),
                height: 300, width: 300, child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/four.jpeg'))),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'And take picture with a shortest distance for getting accuracy in measurement',
                  style: TextStyle( color: Colors.black,fontSize: 15),
                ),
              ),
              SizedBox(height: 60),
              BrownButton(
                label: 'CONTINUE',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen())
                  );
                },
              ),
            ],
          ),
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
