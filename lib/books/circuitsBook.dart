import 'package:flutter/material.dart';

class CircuitsBook extends StatelessWidget {
  const CircuitsBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrical Circuits'), // Removed centerTitle, toolbarHeight
      ),
      body: Center(
        child: Text(
          'Electrical Circuits content will be available soon.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
