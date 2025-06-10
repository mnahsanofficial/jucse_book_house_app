import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart'; // Imports CourseListPage, CourseMaterialsPage
import 'package:jucse_book_house/services.dart'; // Imports DataService
import 'package:jucse_book_house/models.dart';   // Imports Course, Semester models

// Removed obsolete import: import 'package:jucse_book_house/books/physicsBook.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Map<String, String> mockJsonAssets = {};

  // --- Mock JSON String Constants (aligned with new data model) ---
  const String mockSemestersJsonValid = '''
  [{"id":"s1","name":"Semester 1","courseIds":["c1","c2"]}]
  ''';
  const String mockCoursesJsonUpdated = '''
  [
    {"id":"c1","title":"Course Alpha","semesterId":"s1"},
    {"id":"c2","title":"Course Beta","semesterId":"s1"}
  ]
  ''';
  // These are needed because DataService._loadData always loads all JSONs
  const String mockTeachersJsonValid = '''
  [{"id":"t1","name":"Teacher Gamma"}]
  ''';
  const String mockStudyMaterialsJsonValid = '''
  [
    {"id":"sm1","title":"PDF Material Alpha","type":"pdf","path":"assets/file.pdf","isLocal":true,"courseId":"c1","teacherId":"t1"}
  ]
  ''';


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

  void setupDefaultMockAssets() {
    addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid);
    addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);
    addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonValid);
    addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsJsonValid);
  }


  group('CourseListPage Tests', () {
    testWidgets('displays loading indicator and then courses', (WidgetTester tester) async {
      setupDefaultMockAssets();

      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "s1", semesterName: "Semester 1")));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text("Course Alpha"), findsOneWidget);
      expect(find.text("Course Beta"), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays "No courses" message', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"s1","name":"Semester 1","courseIds":[]}]');
      addMockJsonAsset('assets/data/courses.json', '[]');
      // Still need teachers and studymaterials for DataService._loadData not to have null lists later
      addMockJsonAsset('assets/data/teachers.json', '[]');
      addMockJsonAsset('assets/data/studymaterials.json', '[]');


      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "s1", semesterName: "Semester 1")));
      await tester.pumpAndSettle();
      expect(find.text('No courses found for this semester.'), findsOneWidget);
    });

    testWidgets('navigates to CourseMaterialsPage on course tap', (WidgetTester tester) async {
      setupDefaultMockAssets();

      await tester.pumpWidget(MaterialApp(home: CourseListPage(semesterId: "s1", semesterName: "Semester 1")));
      await tester.pumpAndSettle();

      expect(find.text("Course Alpha"), findsOneWidget);
      await tester.tap(find.text("Course Alpha"));
      await tester.pumpAndSettle();

      // Verify that CourseMaterialsPage is now on screen
      // CourseMaterialsPage AppBar title is the course title ("Course Alpha")
      expect(find.widgetWithText(AppBar, "Course Alpha"), findsOneWidget);
      // CourseMaterialsPage will show its own loading/content, e.g., "General Materials" or specific material
      // For this test, "PDF Material Alpha" is a material for course "c1" (Course Alpha)
      expect(find.text("PDF Material Alpha"), findsOneWidget);
    });
  });
}
