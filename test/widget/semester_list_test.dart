import 'dart:convert'; // For utf8
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For ByteData
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart'; // Imports SemesterList, CourseListPage
import 'package:jucse_book_house/services.dart'; // Imports DataService
import 'package:jucse_book_house/models.dart';   // Imports Semester, Course models

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, String> mockJsonAssets = {};

  // --- Mock JSON String Constants (aligned with new data model) ---
  const String mockSemestersJsonValid = '''
  [{"id":"s1","name":"Semester 1 Test","courseIds":["c1"]}]
  ''';
   const String mockSemestersJsonForNavTest = '''
  [{"id":"s1","name":"Test Semester","courseIds":["c1_nav"]}]
  ''';
  const String mockCoursesJson_s1_c1 = '''
  [{"id":"c1","title":"Course For SemesterList Test","semesterId":"s1"}]
  ''';
  const String mockCoursesJson_s1_c1_nav = '''
  [{"id":"c1_nav","title":"Test Course For Navigation","semesterId":"s1"}]
  ''';
  // These are needed because DataService._loadData always loads all JSONs
  const String mockTeachersJsonEmpty = '[]';
  const String mockStudyMaterialsJsonEmpty = '[]';


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

  void simulateMissingAsset(String assetPath) {
    mockJsonAssets.remove(assetPath);
  }

  // Helper to set up default empty versions of all JSONs DataService tries to load
  void setupBaseMockAssets() {
    addMockJsonAsset('assets/data/semesters.json', '[]');
    addMockJsonAsset('assets/data/courses.json', '[]');
    addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonEmpty);
    addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsJsonEmpty);
  }


  testWidgets('SemesterList displays loading indicator initially then semesters', (WidgetTester tester) async {
    setupBaseMockAssets(); // Start with base (mostly empty)
    addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid); // Override with specific semester
    addMockJsonAsset('assets/data/courses.json', mockCoursesJson_s1_c1); // Provide course for s1

    await tester.pumpWidget(MaterialApp(home: SemesterList()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text("Semester 1 Test"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'Details'), findsOneWidget);
  });

  testWidgets('SemesterList displays error message if semester loading fails', (WidgetTester tester) async {
    setupBaseMockAssets(); // Load other JSONs to avoid unrelated errors
    simulateMissingAsset('assets/data/semesters.json'); // Simulate missing semesters

    await tester.pumpWidget(MaterialApp(home: SemesterList()));
    await tester.pumpAndSettle();

    expect(find.text('No semesters found.'), findsOneWidget);
  });

  testWidgets('SemesterList navigates to CourseListPage on Details button tap', (WidgetTester tester) async {
    setupBaseMockAssets(); // Load all JSONs
    addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonForNavTest);
    addMockJsonAsset('assets/data/courses.json', mockCoursesJson_s1_c1_nav);
    // CourseListPage will then try to load courses for "s1", which includes "c1_nav"
    // CourseMaterialsPage (navigated from CourseListPage) will need studymaterials & teachers for "c1_nav"
    // For this test, we are only checking navigation to CourseListPage and if it displays its title & initial content.
    // CourseListPage itself will show "No courses" if its own specific course list is empty based on its semesterId.
    // The mockCoursesJson_s1_c1_nav provides the course it will display.

    await tester.pumpWidget(MaterialApp(home: SemesterList()));
    await tester.pumpAndSettle();

    expect(find.text("Test Semester"), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Details'));
    await tester.pumpAndSettle();

    // Verify that CourseListPage is now in the widget tree
    // CourseListPage AppBar title is the semester name
    expect(find.widgetWithText(AppBar, "Test Semester"), findsOneWidget);
    // CourseListPage body will show courses.
    expect(find.text("Test Course For Navigation"), findsOneWidget);
  });
}
