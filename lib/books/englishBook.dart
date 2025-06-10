import 'package:flutter/material.dart';

class EnglishBook extends StatelessWidget {
  const EnglishBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communicative English'), // Removed centerTitle, toolbarHeight
      ),
      body: Center(
        child: Text(
          'Communicative English content will be available soon.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
