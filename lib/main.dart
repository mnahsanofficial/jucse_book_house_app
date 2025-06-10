import 'package:flutter/material.dart';
import 'package:jucse_book_house/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Added this line
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          toolbarHeight: 100,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 35, color: Colors.white),
          backgroundColor: Colors.blue, // Explicitly set for clarity
          elevation: 4.0,
        ),
      ),
      home: home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

