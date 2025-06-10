import 'package:flutter/material.dart';

class PhysicsBook extends StatelessWidget {
  const PhysicsBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Physics'), // Removed centerTitle, toolbarHeight
      ),
      body: Center(
        child: Text(
          'Physics content will be available soon.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
