import 'dart:convert'; // For utf8
import 'package:flutter/services.dart'; // For ByteData
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataService dataService;
  final Map<String, String> mockJsonAssets = {};

  // --- Mock JSON String Constants ---
  const String mockSemestersJsonValid = '''
  [{"id":"s1","name":"Semester 1","courseIds":["c1","c2"]}]
  ''';
  const String mockCoursesJsonUpdated = '''
  [
    {"id":"c1","title":"Course Alpha","semesterId":"s1"},
    {"id":"c2","title":"Course Beta","semesterId":"s1"}
  ]
  ''';
  const String mockTeachersJsonValid = '''
  [
    {"id":"t1","name":"Teacher Gamma"},
    {"id":"t2","name":"Teacher Delta"}
  ]
  ''';
  const String mockStudyMaterialsJsonValid = '''
  [
    {"id":"sm1","title":"PDF Material Alpha","type":"pdf","path":"assets/file.pdf","isLocal":true,"courseId":"c1","teacherId":"t1"},
    {"id":"sm2","title":"Link Material Alpha","type":"link","path":"http://example.com","isLocal":false,"courseId":"c1","teacherId":null},
    {"id":"sm3","title":"Note Material Beta","type":"note","path":"This is a note.","isLocal":false,"courseId":"c2","teacherId":"t1"},
    {"id":"sm4","title":"PDF Material Beta","type":"pdf","path":"assets/file2.pdf","isLocal":true,"courseId":"c2","teacherId":"t2"}
  ]
  ''';
  const String mockEmptyListJson = '[]';

  setUp(() {
    dataService = DataService();
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

  // --- Helper to setup all valid default assets ---
  void setupAllValidMockAssets() {
    addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid);
    addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);
    addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonValid);
    addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsJsonValid);
  }


  group('DataService - Successful Data Loading', () {
    test('loads semesters successfully', () async {
      setupAllValidMockAssets();
      final semesters = await dataService.getSemesters();
      expect(semesters, isNotEmpty);
      expect(semesters.first.name, "Semester 1");
    });

    test('loads courses for a semester successfully', () async {
      setupAllValidMockAssets();
      final courses = await dataService.getCoursesForSemester("s1");
      expect(courses, isNotEmpty);
      expect(courses.length, 2);
      expect(courses.any((c) => c.id == 'c1'), isTrue);
    });

    test('loads teachers successfully', () async {
      setupAllValidMockAssets();
      final teachers = await dataService.getTeachers();
      expect(teachers, isNotEmpty);
      expect(teachers.length, 2);
      expect(teachers.first.name, "Teacher Gamma");
    });

    test('loads study materials successfully (all for a course)', () async {
      setupAllValidMockAssets();
      final materials = await dataService.getStudyMaterialsForCourse("c1");
      expect(materials, isNotEmpty);
      expect(materials.length, 2);
      expect(materials.any((m) => m.id == 'sm1'), isTrue);
    });
  });

  group('DataService - Corrupted/Missing JSON', () {
    test('handles missing semesters.json gracefully', () async {
      simulateMissingAsset('assets/data/semesters.json');
      addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);
      addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonValid);
      addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsJsonValid);

      final semesters = await dataService.getSemesters();
      expect(semesters, isEmpty);
    });

    test('handles malformed teachers.json gracefully', () async {
      addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid);
      addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);
      addMockJsonAsset('assets/data/teachers.json', 'this is not json');
      addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsJsonValid);

      final teachers = await dataService.getTeachers();
      expect(teachers, isEmpty);
    });

    test('handles missing studymaterials.json gracefully', () async {
      addMockJsonAsset('assets/data/semesters.json', mockSemestersJsonValid);
      addMockJsonAsset('assets/data/courses.json', mockCoursesJsonUpdated);
      addMockJsonAsset('assets/data/teachers.json', mockTeachersJsonValid);
      simulateMissingAsset('assets/data/studymaterials.json');

      final materials = await dataService.getStudyMaterialsForCourse("c1");
      expect(materials, isEmpty);
    });
  });

  group('DataService - Method Logic', () {
    setUp(() {
      // Ensure all data is loaded for method logic tests by default
      setupAllValidMockAssets();
    });

    test('getCourseDetails returns course for valid ID', () async {
      final course = await dataService.getCourseDetails("c1");
      expect(course, isNotNull);
      expect(course!.title, "Course Alpha");
    });

    test('getCourseDetails returns null for invalid courseId', () async {
      final course = await dataService.getCourseDetails("invalid_id");
      expect(course, isNull);
    });

    test('getTeacherDetails returns teacher for valid ID', () async {
      final teacher = await dataService.getTeacherDetails("t1");
      expect(teacher, isNotNull);
      expect(teacher!.name, "Teacher Gamma");
    });

    test('getTeacherDetails returns null for invalid teacherId', () async {
      final teacher = await dataService.getTeacherDetails("invalid_id");
      expect(teacher, isNull);
    });

    test('getStudyMaterialDetails returns material for valid ID', () async {
      final material = await dataService.getStudyMaterialDetails("sm1");
      expect(material, isNotNull);
      expect(material!.title, "PDF Material Alpha");
    });

    test('getStudyMaterialDetails returns null for invalid materialId', () async {
      final material = await dataService.getStudyMaterialDetails("invalid_id");
      expect(material, isNull);
    });

    test('getStudyMaterialsForCourse returns materials for valid courseId', () async {
      final materials = await dataService.getStudyMaterialsForCourse("c1");
      expect(materials, isNotEmpty);
      expect(materials.length, 2);
    });

    test('getStudyMaterialsForCourse returns empty list for course with no materials', () async {
      addMockJsonAsset('assets/data/courses.json', '''
        [${mockCoursesJsonUpdated.substring(1, mockCoursesJsonUpdated.length-1)},
         {"id":"c3","title":"Course Empty","semesterId":"s1"}]
      '''); // Add a course c3 with no materials
      final materials = await dataService.getStudyMaterialsForCourse("c3");
      expect(materials, isEmpty);
    });

    test('getStudyMaterialsForCourse returns empty list for invalid courseId', () async {
      final materials = await dataService.getStudyMaterialsForCourse("invalid_id");
      expect(materials, isEmpty);
    });

    test('getStudyMaterialsForCourseByTeacher returns correct materials', () async {
      final materials = await dataService.getStudyMaterialsForCourseByTeacher("c1", "t1");
      expect(materials, isNotEmpty);
      expect(materials.length, 1);
      expect(materials.first.id, "sm1");
    });

    test('getStudyMaterialsForCourseByTeacher returns empty if teacher has no materials for course', () async {
      final materials = await dataService.getStudyMaterialsForCourseByTeacher("c1", "t2"); // t2 has no materials for c1
      expect(materials, isEmpty);
    });

    test('getTeachersForCourse returns correct teachers', () async {
      final teachers = await dataService.getTeachersForCourse('c1'); // sm1 by t1, sm2 general
      expect(teachers, isNotEmpty);
      expect(teachers.length, 1);
      expect(teachers.first.id, 't1');

      final teachersForC2 = await dataService.getTeachersForCourse('c2'); // sm3 by t1, sm4 by t2
      expect(teachersForC2, isNotEmpty);
      expect(teachersForC2.length, 2); // t1 and t2
      expect(teachersForC2.any((t) => t.id == 't1'), isTrue);
      expect(teachersForC2.any((t) => t.id == 't2'), isTrue);
    });

    test('getTeachersForCourse returns empty list if no teachers associated', () async {
       // Add a course c3 and a general material for it
      addMockJsonAsset('assets/data/courses.json', '''
        [${mockCoursesJsonUpdated.substring(1, mockCoursesJsonUpdated.length-1)},
         {"id":"c3","title":"Course GeneralOnly","semesterId":"s1"}]''');
      addMockJsonAsset('assets/data/studymaterials.json', '''
        [${mockStudyMaterialsJsonValid.substring(1, mockStudyMaterialsJsonValid.length-1)},
         {"id":"sm_general","title":"General Mat","type":"note","path":"...","isLocal":false,"courseId":"c3","teacherId":null}]
      ''');
      final teachers = await dataService.getTeachersForCourse('c3');
      expect(teachers, isEmpty);
    });
  });
}
