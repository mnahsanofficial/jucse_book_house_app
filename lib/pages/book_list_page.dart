import 'package:flutter/material.dart';
import 'package:jucse_book_house/models.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/pages/book_viewer_page.dart'; // Will be created

class BookListPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const BookListPage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late Future<List<Book>> _booksFuture;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _booksFuture = _dataService.getBooksForCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading books: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books found for this course.'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: Icon(Icons.menu_book_outlined),
                title: Text(book.title, style: TextStyle(fontSize: 22)),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookViewerPage(
                        bookId: book.id,
                        bookTitle: book.title,
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
