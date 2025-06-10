import 'package:flutter/material.dart';
import 'package:jucse_book_house/models.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/pages/book_list_page.dart'; // New
import 'package:jucse_book_house/pages/book_viewer_page.dart'; // New
// Old direct imports - will be removed if no longer directly used
// import 'package:jucse_book_house/books/calculusBook.dart';
// import 'package:jucse_book_house/books/economicsBooksListPage.dart';
// Imports for placeholder pages for courses with no content
import 'package:jucse_book_house/books/physicsBook.dart';
import 'package:jucse_book_house/books/englishBook.dart';
import 'package:jucse_book_house/books/circuitsBook.dart';
import 'package:jucse_book_house/books/circuitsLabBook.dart';


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
                leading: Icon(Icons.menu_book_outlined),
                title: Text(course.title, style: TextStyle(fontSize: 22)),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () async {
                  // Fetch full course details to ensure 'hasContent' and 'bookIds' are accurate
                  final detailedCourse = await _dataService.getCourseDetails(course.id);
                  if (detailedCourse == null) {
                     ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Course details not found!')),
                      );
                    return;
                  }

                  if (detailedCourse.hasContent) {
                    // Fetch the actual books for the course to decide navigation
                    final books = await _dataService.getBooksForCourse(detailedCourse.id);

                    if (books.length > 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookListPage(
                            courseId: detailedCourse.id,
                            courseTitle: detailedCourse.title,
                          ),
                        ),
                      );
                    } else if (books.length == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookViewerPage(
                            bookId: books.first.id,
                            bookTitle: books.first.title,
                          ),
                        ),
                      );
                    } else { // No books found, even if hasContent might be true
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No books found for ${detailedCourse.title}.')),
                      );
                    }
                  } else {
                    // Navigate to existing placeholder pages based on course ID
                    Widget placeholderPage;
                    switch (detailedCourse.id) {
                      case 'cse103': // Physics
                        placeholderPage = PhysicsBook();
                        break;
                      case 'cse109': // Communicative English
                        placeholderPage = EnglishBook();
                        break;
                      case 'cse107': // Electrical Circuits
                        placeholderPage = CircuitsBook();
                        break;
                      case 'cse107L': // Electrical Circuits Laboratory
                        placeholderPage = CircuitsLabBook();
                        break;
                      default:
                        // Generic placeholder if specific one isn't defined
                        placeholderPage = Scaffold(
                          appBar: AppBar(title: Text(detailedCourse.title)),
                          body: Center(child: Text('${detailedCourse.title} content will be available soon.')),
                        );
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => placeholderPage),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
