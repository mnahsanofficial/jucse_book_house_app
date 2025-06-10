import 'package:flutter/material.dart';
import 'package:jucse_book_house/models.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/pages.dart'; // Updated import

// Removed old semester page imports as they will be obsolete
// import 'package:jucse_book_house/semester/firstSemester.dart';
// ... and others

class SemesterList extends StatefulWidget { // Changed to StatefulWidget
  const SemesterList({Key? key}) : super(key: key);

  @override
  _SemesterListState createState() => _SemesterListState();
}

class _SemesterListState extends State<SemesterList> {
  late Future<List<Semester>> _semestersFuture;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _semestersFuture = _dataService.getSemesters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semester List'),
      ),
      body: FutureBuilder<List<Semester>>(
        future: _semestersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No semesters found.'));
          }

          final semesters = snapshot.data!;
          return Center( // Added Center to mimic original layout for GridView
            child: GridView.extent(
              primary: false,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              maxCrossAxisExtent: 200.0,
              children: semesters.map((semester) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(semester.name, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Details', style: TextStyle(fontSize: 20.0)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseListPage(
                              semesterId: semester.id,
                              semesterName: semester.name,
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
                  color: Colors.blue, // Keeping the original container color
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
