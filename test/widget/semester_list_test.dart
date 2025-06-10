import 'dart:convert'; // For utf8
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For ByteData
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart'; // Imports SemesterList, CourseListPage
import 'package:jucse_book_house/services.dart'; // Imports DataService
// Models are implicitly used by DataService and pages

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // DataService will be instantiated by SemesterList internally.
  // We just need to mock the asset loading.
  final Map<String, String> mockJsonAssets = {};

  setUp(() {
    mockJsonAssets.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final String assetPath = utf8.decode(message.buffer.asUint8List());
      // print("WidgetTest MockAssetHandler: Request for $assetPath"); // For debugging
      if (mockJsonAssets.containsKey(assetPath)) {
        return ByteData.view(utf8.encoder.convert(mockJsonAssets[assetPath]!).buffer);
      }
      // print("WidgetTest MockAssetHandler: Asset not found: $assetPath"); // For debugging
      return null;
    });
  });

  void addMockJsonAsset(String assetPath, String jsonString) {
    mockJsonAssets[assetPath] = jsonString;
  }

  void simulateMissingAsset(String assetPath) {
    mockJsonAssets.remove(assetPath);
  }

  testWidgets('SemesterList displays loading indicator initially then semesters', (WidgetTester tester) async {
    // Mock data - DataService will be called by SemesterList's initState
    addMockJsonAsset('assets/data/semesters.json', '[{"id":"s1","name":"Semester 1 Test","courseIds":[]}]');
    addMockJsonAsset('assets/data/courses.json', '[]'); // Needed by DataService._loadData
    addMockJsonAsset('assets/data/books.json', '[]');   // Needed by DataService._loadData

    await tester.pumpWidget(MaterialApp(home: SemesterList()));

    // Initially, CircularProgressIndicator should be shown while waiting for Future
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump and settle to allow FutureBuilder to resolve and UI to update
    await tester.pumpAndSettle();

    // After loading, semester name should be visible
    expect(find.text("Semester 1 Test"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing); // No longer loading
    expect(find.widgetWithText(ElevatedButton, 'Details'), findsOneWidget); // Check for details button
  });

  testWidgets('SemesterList displays error message if semester loading fails', (WidgetTester tester) async {
    // Simulate missing semesters.json
    simulateMissingAsset('assets/data/semesters.json');
    addMockJsonAsset('assets/data/courses.json', '[]'); // Still provide others for _loadData
    addMockJsonAsset('assets/data/books.json', '[]');

    await tester.pumpWidget(MaterialApp(home: SemesterList()));
    await tester.pumpAndSettle(); // Allow Future to complete (with error or empty data)

    // Based on DataService error handling, _semesters will be [], so SemesterList should show "No semesters found"
    // or an error message if the Future itself fails more catastrophically.
    // DataService now returns [] for semesters if semesters.json is missing/corrupt.
    // The FutureBuilder in SemesterList will then find snapshot.data to be empty.
    expect(find.text('No semesters found.'), findsOneWidget);
  });

  testWidgets('SemesterList navigates to CourseListPage on Details button tap', (WidgetTester tester) async {
    // Mock data for SemesterList
    addMockJsonAsset('assets/data/semesters.json', '[{"id":"s1","name":"Test Semester","courseIds":["c1"]}]');
    // Mock data for DataService._loadData called by SemesterList AND CourseListPage
    addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Test Course","semesterId":"s1","bookIds":[],"hasContent":false}]');
    addMockJsonAsset('assets/data/books.json', '[]');

    await tester.pumpWidget(MaterialApp(home: SemesterList()));
    await tester.pumpAndSettle();

    expect(find.text("Test Semester"), findsOneWidget);

    // Find the 'Details' button and tap it
    await tester.tap(find.widgetWithText(ElevatedButton, 'Details'));
    await tester.pumpAndSettle(); // Allow navigation to complete

    // Verify that CourseListPage is now in the widget tree
    // CourseListPage AppBar title is the semester name
    expect(find.widgetWithText(AppBar, "Test Semester"), findsOneWidget);
    // CourseListPage body will show courses, or "No courses" if empty, or loading.
    // Here, it should find "Test Course" from the mock data.
    expect(find.text("Test Course"), findsOneWidget);
  });
}
