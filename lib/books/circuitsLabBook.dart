import 'package:flutter/material.dart';

class CircuitsLabBook extends StatelessWidget {
  const CircuitsLabBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrical Circuits Labratory'), // Removed centerTitle, toolbarHeight
      ),
      body: Center(
        child: Text(
          'Electrical Circuits Labratory content will be available soon.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
