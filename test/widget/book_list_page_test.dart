import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Map<String, String> mockJsonAssets = {};

  setUp(() {
    mockJsonAssets.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final String assetPath = utf8.decode(message.buffer.asUint8List());
      if (mockJsonAssets.containsKey(assetPath)) {
        return ByteData.view(utf8.encoder.convert(mockJsonAssets[assetPath]!).buffer);
      }
      return null;
    });
  });

  void addMockJsonAsset(String assetPath, String jsonString) {
    mockJsonAssets[assetPath] = jsonString;
  }

  group('BookListPage Tests', () {
    testWidgets('displays books for a course', (WidgetTester tester) async {
      // Semesters.json is not strictly needed by BookListPage itself, but DataService loads all JSONs.
      addMockJsonAsset('assets/data/semesters.json', '[]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Test Course","semesterId":"s1","bookIds":["b1","b2"],"hasContent":true}]');
      addMockJsonAsset('assets/data/books.json', '[{"id":"b1","title":"Book Alpha","pdfPath":"","isLocal":true},{"id":"b2","title":"Book Beta","pdfPath":"","isLocal":false}]');

      await tester.pumpWidget(MaterialApp(home: BookListPage(courseId: "c1", courseTitle: "Test Course")));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text("Book Alpha"), findsOneWidget);
      expect(find.text("Book Beta"), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays "No books" message if course has no books', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', '[]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c2","title":"Course NoBooks","semesterId":"s1","bookIds":[],"hasContent":true}]'); // hasContent true, but empty bookIds
      addMockJsonAsset('assets/data/books.json', '[]');

      await tester.pumpWidget(MaterialApp(home: BookListPage(courseId: "c2", courseTitle: "Course NoBooks")));
      await tester.pumpAndSettle();

      expect(find.text('No books found for this course.'), findsOneWidget);
    });

    testWidgets('navigates to BookViewerPage on book tap', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', '[]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Test Course","semesterId":"s1","bookIds":["b1"],"hasContent":true}]');
      addMockJsonAsset('assets/data/books.json', '[{"id":"b1","title":"Book Alpha","pdfPath":"assets/pdf/calculus.pdf","isLocal":true}]');
      // For BookViewerPage to load, it will also need books.json to get details for "b1"
      // The current setup for addMockJsonAsset makes it available to all DataService instances.

      await tester.pumpWidget(MaterialApp(
        home: BookListPage(courseId: "c1", courseTitle: "Test Course"),
        // Define routes if BookViewerPage uses named routes, or ensure it's pushable.
        // For this test, direct push is fine.
      ));
      await tester.pumpAndSettle();

      expect(find.text("Book Alpha"), findsOneWidget);
      await tester.tap(find.text("Book Alpha"));
      await tester.pumpAndSettle();

      // BookViewerPage's AppBar title is the book title
      expect(find.widgetWithText(AppBar, "Book Alpha"), findsOneWidget);
    });
  });
}
