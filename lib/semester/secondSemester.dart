import 'package:flutter/material.dart';

import '../books/calculusBook.dart';
class secondSemester extends StatelessWidget {
  const secondSemester({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 100,
            title:Text("First Semester" ,style: TextStyle(fontSize: 35),)
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('CSE-101: Mathematics I (Calculus and Coordinate Geometry'  ,style: TextStyle(fontSize: 25),),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push
                  (context,
                    MaterialPageRoute(builder: (context)
                    {
                      return calculusBook();

                    }));
              },
            ),
            ListTile(
              title: Text('CSE-103:Physics (Electricity,Magnetism and Optics)' ,style: TextStyle(fontSize: 25),),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print('Sun');
              },
            ),
            ListTile(
              title: Text('CSE-109:Communicative English' ,style: TextStyle(fontSize: 25),),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print('Sun');
              },
            ),
            ListTile(
              title: Text('CSE-107:Electrical Circuits' ,style: TextStyle(fontSize: 25),),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print('Sun');
              },
            ),
            ListTile(
              title: Text('CSE-107:Electrical Circuits Labratory' ,style: TextStyle(fontSize: 25),),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print('Sun');
              },
            ),
            ListTile(
              title: Text('CSE-111:Economics' ,style: TextStyle(fontSize: 25),),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                print('Sun');
              },
            ),
          ],
        )
    );
  }
}

