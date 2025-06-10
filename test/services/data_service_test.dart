import 'dart:convert'; // For utf8
import 'package:flutter/services.dart'; // For ByteData
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Important!

  late DataService dataService;
  // Using a simple Map to store String content for assets, DataService handles parsing
  final Map<String, String> mockJsonAssets = {};

  setUp(() {
    dataService = DataService(); // Re-initialize service for each test
    mockJsonAssets.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final String assetPath = utf8.decode(message.buffer.asUint8List());
      // print("MockAssetHandler: Request for $assetPath"); // For debugging tests
      if (mockJsonAssets.containsKey(assetPath)) {
        return ByteData.view(utf8.encoder.convert(mockJsonAssets[assetPath]!).buffer);
      }
      // print("MockAssetHandler: Asset not found in mock: $assetPath"); // For debugging tests
      return null; // Simulate asset not found if not in our mock map
    });
  });

  // Helper to add mock JSON assets
  void addMockJsonAsset(String assetPath, String jsonString) {
    mockJsonAssets[assetPath] = jsonString;
  }

  // Helper to simulate a missing asset (ensures it's not in the map)
  void simulateMissingAsset(String assetPath) {
    mockJsonAssets.remove(assetPath);
  }

  group('DataService - Successful Data Loading', () {
    test('loads semesters successfully', () async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"S1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Course 1","semesterId":"sem1","bookIds":[],"hasContent":false}]');
      addMockJsonAsset('assets/data/books.json', '[]');

      final semesters = await dataService.getSemesters();
      expect(semesters, isNotEmpty);
      expect(semesters.first.name, "S1");
    });

    test('loads courses for a semester successfully', () async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"S1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Course 1","semesterId":"sem1","bookIds":[],"hasContent":false}]');
      addMockJsonAsset('assets/data/books.json', '[]');

      final courses = await dataService.getCoursesForSemester("sem1");
      expect(courses, isNotEmpty);
      expect(courses.first.title, "Course 1");
    });

    test('loads books for a course successfully', () async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"S1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Course 1","semesterId":"sem1","bookIds":["b1"],"hasContent":true}]');
      addMockJsonAsset('assets/data/books.json', '[{"id":"b1","title":"Book 1","pdfPath":"","isLocal":true}]');

      final books = await dataService.getBooksForCourse("c1");
      expect(books, isNotEmpty);
      expect(books.first.title, "Book 1");
    });
  });

  group('DataService - Corrupted/Missing JSON', () {
    test('handles missing semesters.json gracefully (returns empty list)', () async {
      simulateMissingAsset('assets/data/semesters.json');
      addMockJsonAsset('assets/data/courses.json', '[]'); // courses and books must exist to avoid other errors during _loadData
      addMockJsonAsset('assets/data/books.json', '[]');

      final semesters = await dataService.getSemesters();
      expect(semesters, isEmpty);
    });

    test('handles malformed semesters.json gracefully (returns empty list)', () async {
      addMockJsonAsset('assets/data/semesters.json', 'this is not json');
      addMockJsonAsset('assets/data/courses.json', '[]');
      addMockJsonAsset('assets/data/books.json', '[]');

      final semesters = await dataService.getSemesters();
      expect(semesters, isEmpty);
    });

     test('handles missing courses.json gracefully (getCoursesForSemester returns empty)', () async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"S1","courseIds":["c1"]}]');
      simulateMissingAsset('assets/data/courses.json');
      addMockJsonAsset('assets/data/books.json', '[]');

      final courses = await dataService.getCoursesForSemester("sem1");
      expect(courses, isEmpty); // As _courses would be [] in DataService
    });

    test('handles missing books.json gracefully (getBooksForCourse returns empty)', () async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"S1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Course 1","semesterId":"sem1","bookIds":["b1"],"hasContent":true}]');
      simulateMissingAsset('assets/data/books.json');

      final books = await dataService.getBooksForCourse("c1");
      expect(books, isEmpty); // As _books would be [] in DataService
    });
  });

  group('DataService - Method Logic', () {
    test('getCourseDetails returns null for invalid courseId', () async {
      addMockJsonAsset('assets/data/semesters.json', '[]');
      addMockJsonAsset('assets/data/courses.json', '[]'); // Empty but valid JSON
      addMockJsonAsset('assets/data/books.json', '[]');

      final course = await dataService.getCourseDetails("invalid_course_id");
      expect(course, isNull);
    });

    test('getBookDetails returns null for invalid bookId', () async {
      addMockJsonAsset('assets/data/semesters.json', '[]');
      addMockJsonAsset('assets/data/courses.json', '[]');
      addMockJsonAsset('assets/data/books.json', '[]'); // Empty but valid JSON

      final book = await dataService.getBookDetails("invalid_book_id");
      expect(book, isNull);
    });

    test('getCoursesForSemester returns empty list for invalid semesterId', () async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"S1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Course 1","semesterId":"sem1","bookIds":[],"hasContent":false}]');
      addMockJsonAsset('assets/data/books.json', '[]');

      final courses = await dataService.getCoursesForSemester("invalid_semester_id");
      expect(courses, isEmpty);
    });

    test('getBooksForCourse returns empty list for invalid courseId', () async {
      addMockJsonAsset('assets/data/semesters.json', '[{"id":"sem1","name":"S1","courseIds":["c1"]}]');
      addMockJsonAsset('assets/data/courses.json', '[{"id":"c1","title":"Course 1","semesterId":"sem1","bookIds":["b1"],"hasContent":true}]');
      addMockJsonAsset('assets/data/books.json', '[{"id":"b1","title":"Book 1","pdfPath":"","isLocal":true}]');

      final books = await dataService.getBooksForCourse("invalid_course_id");
      expect(books, isEmpty);
    });
  });
}
