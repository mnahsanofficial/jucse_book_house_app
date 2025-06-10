import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/models.dart';
// Import placeholder pages for hasContent:false navigation check
import 'package:jucse_book_house/books/physicsBook.dart';


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

  group('CourseListPage Tests', () {
    testWidgets('displays loading indicator and then courses', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"Semester 1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Test Course 1","semesterId":"sem1","bookIds":[],"hasContent":true}]');
      addMockJsonAsset('assets/data/books.json', '[]');

      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "sem1", semesterName: "Semester 1")));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text("Test Course 1"), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays "No courses" message', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"Semester 1","courseIds":[]}]');
      addMockJsonAsset('assets/data/courses.json', '[]');
      addMockJsonAsset('assets/data/books.json', '[]');

      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "sem1", semesterName: "Semester 1")));
      await tester.pumpAndSettle();
      expect(find.text('No courses found for this semester.'), findsOneWidget);
    });

    testWidgets('navigates to BookListPage for multi-book course', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"Semester 1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Multi Book Course","semesterId":"sem1","bookIds":["b1","b2"],"hasContent":true}]');
      addMockJsonAsset('assets/data/books.json', '[{"id":"b1","title":"Book 1","pdfPath":"","isLocal":true},{"id":"b2","title":"Book 2","pdfPath":"","isLocal":true}]');

      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "sem1", semesterName: "Semester 1")));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Multi Book Course"));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, "Multi Book Course"), findsOneWidget);
      expect(find.text("Book 1"), findsOneWidget);
    });

    testWidgets('navigates to BookViewerPage for single-book course', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"Semester 1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Single Book Course","semesterId":"sem1","bookIds":["b1"],"hasContent":true}]');
      addMockJsonAsset('assets/data/books.json', '[{"id":"b1","title":"The Only Book","pdfPath":"assets/pdf/calculus.pdf","isLocal":true}]');

      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "sem1", semesterName: "Semester 1")));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Single Book Course"));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, "The Only Book"), findsOneWidget);
    });

    testWidgets('navigates to placeholder page for course with no content', (WidgetTester tester) async {
      // Corrected course ID to 'cse103' to match specific case in CourseListPage
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"Semester 1","courseIds":["cse103"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"cse103","title":"Physics","semesterId":"sem1","bookIds":[],"hasContent":false}]');
      addMockJsonAsset('assets/data/books.json', '[]');

      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "sem1", semesterName: "Semester 1")));
      await tester.pumpAndSettle();

      // Course title from JSON is "Physics"
      await tester.tap(find.text("Physics"));
      await tester.pumpAndSettle();

      // PhysicsBook (placeholder) itself has AppBar title "Physics"
      expect(find.widgetWithText(AppBar, "Physics"), findsNWidgets(2)); // One for CourseListPage, one for PhysicsBook
      expect(find.text('Physics content will be available soon.'), findsOneWidget);
    });
  });
}
