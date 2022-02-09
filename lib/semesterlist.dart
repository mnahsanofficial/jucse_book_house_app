import 'package:flutter/material.dart';
import 'package:jucse_book_house/home.dart';
import 'package:jucse_book_house/semester/eighthSemester.dart';
import 'package:jucse_book_house/semester/fifthSemester.dart';
import 'package:jucse_book_house/semester/firstSemester.dart';
import 'package:jucse_book_house/semester/fourthSemester.dart';
import 'package:jucse_book_house/semester/secondSemester.dart';
import 'package:jucse_book_house/semester/seventhSemester.dart';
import 'package:jucse_book_house/semester/sixthSemester.dart';
import 'package:jucse_book_house/semester/thirdSemester.dart';
class semesterList extends StatelessWidget {
  const semesterList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text('Semester List', style: TextStyle(fontSize: 35),),
        centerTitle: true,
      ),
      body: Center(
          child: GridView.extent(
            primary: false,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            maxCrossAxisExtent: 200.0,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('First Semester', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return firstSemester();

                              })),)
                      ],
                    )),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Second Semester', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return secondSemester();

                              })),)

                      ],
                    )),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Third', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return thirdSemester();

                              })),)
                      ],
                    )),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Four Semester', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return fourthSemester();

                              })),)
                      ],
                    )),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Fifth Semester', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return fifthSemester();

                              })),)
                      ],
                    )),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sixth Semester', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return sixthSemester();

                              })),)
                      ],
                    )),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Seventh \nSemester', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return seventhSemester();

                              })),)
                      ],
                    )),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Eight Semester', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20,),
                        FlatButton(child: Text('Details' ,style: TextStyle(fontSize: 20.0),),
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          onPressed: () => Navigator.push
                            (context,
                              MaterialPageRoute(builder: (context)
                              {
                                return eighthSemester();

                              })),)
                      ],
                    )),
                color: Colors.blue,
              ),
            ],
          )),
    );
  }
}
