import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart'; // Imports CourseMaterialsPage, StudyMaterialViewerPage
import 'package:jucse_book_house/services.dart'; // Imports DataService
import 'package:jucse_book_house/models.dart';   // Imports relevant models

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Map<String, String> mockJsonAssets = {};

  // --- Mock JSON String Constants ---
  const String mockSemestersJsonValid = '''
  [{"id":"s1","name":"Semester 1","courseIds":["c1"]}]
  '''; // Not directly used by CourseMaterialsPage but DataService loads it.
  const String mockCoursesJsonUpdated = '''
  [{"id":"c1","title":"Test Course for Materials","semesterId":"s1"}]
  '''; // Course title will be the AppBar title.
  const String mockTeachersJsonValid = '''
  [
    {"id":"t1","name":"Teacher Alpha"},
    {"id":"t2","name":"Teacher Beta"}
  ]
  ''';
  const String mockStudyMaterialsJson_CourseC1 = '''
  [
    {"id":"sm_gen1","title":"General PDF 1","type":"pdf","path":"assets/gen1.pdf","isLocal":true,"courseId":"c1","teacherId":null},
    {"id":"sm_t1_1","title":"Teacher Alpha PDF 1","type":"pdf","path":"assets/t1_1.pdf","isLocal":true,"courseId":"c1","teacherId":"t1"},
    {"id":"sm_t1_2","title":"Teacher Alpha Link 1","type":"link","path":"http://example.com/t1","isLocal":false,"courseId":"c1","teacherId":"t1"},
    {"id":"sm_t2_1","title":"Teacher Beta Note 1","type":"note","path":"Note from Beta.","isLocal":false,"courseId":"c1","teacherId":"t2"}
  ]
  ''';
   const String mockStudyMaterialsJson_CourseC1_NoGeneral = '''
  [
    {"id":"sm_t1_1","title":"Teacher Alpha PDF 1","type":"pdf","path":"assets/t1_1.pdf","isLocal":true,"courseId":"c1","teacherId":"t1"}
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

  void setupDefaultMockDataForCourseC1() {
    addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid);
    addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);
    addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonValid);
    addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsJson_CourseC1);
  }

  group('CourseMaterialsPage Tests', () {
    testWidgets('displays loading indicator then materials grouped by teacher and general', (WidgetTester tester) async {
      setupDefaultMockDataForCourseC1();

      await tester.pumpWidget(MaterialApp(home: CourseMaterialsPage(courseId: "c1", courseTitle: "Test Course for Materials")));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Check for ExpansionTiles
      expect(find.widgetWithText(ExpansionTile, 'General Materials'), findsOneWidget);
      expect(find.widgetWithText(ExpansionTile, 'Teacher Alpha'), findsOneWidget);
      expect(find.widgetWithText(ExpansionTile, 'Teacher Beta'), findsOneWidget);

      // Check for specific materials under these tiles (assuming they are initially expanded)
      expect(find.text('General PDF 1'), findsOneWidget);
      expect(find.text('Teacher Alpha PDF 1'), findsOneWidget);
      expect(find.text('Teacher Alpha Link 1'), findsOneWidget);
      expect(find.text('Teacher Beta Note 1'), findsOneWidget);
    });

    testWidgets('displays "No study materials" message', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid); // Needed for DataService
      addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);   // Needed for DataService
      addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonValid); // Needed for DataService
      addMockJsonAsset('assets/data/studymaterials.json', '[]'); // No study materials for any course

      await tester.pumpWidget(MaterialApp(home: CourseMaterialsPage(courseId: "c1", courseTitle: "Test Course for Materials")));
      await tester.pumpAndSettle();

      expect(find.text('No study materials found for this course.'), findsOneWidget);
    });

    testWidgets('navigates to StudyMaterialViewerPage on material tap', (WidgetTester tester) async {
      setupDefaultMockDataForCourseC1();
      // Mock assets for StudyMaterialViewerPage to load details for "General PDF 1"
      addMockJsonAsset("assets/gen1.pdf", ""); // Dummy content for local PDF asset

      await tester.pumpWidget(MaterialApp(home: CourseMaterialsPage(courseId: "c1", courseTitle: "Test Course for Materials")));
      await tester.pumpAndSettle();

      expect(find.text('General PDF 1'), findsOneWidget);
      await tester.tap(find.text('General PDF 1'));
      await tester.pumpAndSettle();

      // Verify StudyMaterialViewerPage is active (e.g., by its AppBar title - the material title)
      expect(find.widgetWithText(AppBar, 'General PDF 1'), findsOneWidget);
      // Check for SfPdfViewer as "General PDF 1" is a PDF type
      expect(find.byType(SfPdfViewer), findsOneWidget);
    });

    testWidgets('Does not display general section if no general materials', (WidgetTester tester) async {
      addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid);
      addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);
      addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonValid);
      addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsJson_CourseC1_NoGeneral);


      await tester.pumpWidget(MaterialApp(home: CourseMaterialsPage(courseId: "c1", courseTitle: "Test Course for Materials")));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ExpansionTile, 'General Materials'), findsNothing);
      expect(find.widgetWithText(ExpansionTile, 'Teacher Alpha'), findsOneWidget); // Teacher Alpha still has material
      expect(find.text('Teacher Alpha PDF 1'), findsOneWidget);
    });
  });
}
