import 'package:flutter/material.dart';
import 'package:jucse_book_house/models.dart'; // Course model is used
import 'package:jucse_book_house/services.dart'; // DataService is used for getCoursesForSemester
import 'package:jucse_book_house/pages.dart'; // For CourseMaterialsPage

// Unused imports that will be removed by this overwrite:
// import 'package:jucse_book_house/pages/book_list_page.dart';
// import 'package:jucse_book_house/pages/book_viewer_page.dart';
// import 'package:jucse_book_house/books/physicsBook.dart';
// import 'package:jucse_book_house/books/englishBook.dart';
// import 'package:jucse_book_house/books/circuitsBook.dart';
// import 'package:jucse_book_house/books/circuitsLabBook.dart';

class CourseListPage extends StatefulWidget {
  final String semesterId;
  final String semesterName;

  const CourseListPage({
    Key? key,
    required this.semesterId,
    required this.semesterName,
  }) : super(key: key);

  @override
  _CourseListPageState createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  late Future<List<Course>> _coursesFuture;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _coursesFuture = _dataService.getCoursesForSemester(widget.semesterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.semesterName),
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No courses found for this semester.'));
          }

          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                leading: Icon(Icons.menu_book_outlined), // Kept from previous version
                title: Text(course.title, style: TextStyle(fontSize: 22)), // Kept from previous version
                trailing: Icon(Icons.keyboard_arrow_right), // Kept from previous version
                onTap: () { // No longer async
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseMaterialsPage(
                        courseId: course.id,
                        courseTitle: course.title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
