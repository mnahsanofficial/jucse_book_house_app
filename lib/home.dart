import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jucse_book_house/semesterlist.dart';
class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JUCSE Book House', style: TextStyle(fontSize: 35),),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 100,
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
             FlatButton(child: Text('See Semester List' ,style: TextStyle(fontSize: 20.0),),
               color: Colors.blueAccent,
               textColor: Colors.white,
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
