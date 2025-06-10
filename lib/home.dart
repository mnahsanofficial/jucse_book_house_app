import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jucse_book_house/semesterlist.dart';
class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JUCSE Book House'), // Removed style, centerTitle, toolbarHeight
        titleSpacing: 00.0, // Kept this as it wasn't part of the theme
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to \nJUCSE Book House',
                textAlign: TextAlign.center, style:TextStyle(fontSize: 30),),
             SizedBox(height: 20,),
             ElevatedButton(child: Text('See Semester List' ,style: TextStyle(fontSize: 20.0),),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.blueAccent,
                 foregroundColor: Colors.white,
               ),
               onPressed: () => Navigator.push
                (context,
                  MaterialPageRoute(builder: (context)
                  {
                    return semesterList();

              })),)
            ],
          )
          ],
      ),
    );
  }
}
