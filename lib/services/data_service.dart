import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jucse_book_house/models.dart';

class DataService {
  List<Semester>? _semesters;
  List<Course>? _courses;
  // List<Book>? _books; // Removed old _books field
  List<Teacher>? _teachers;
  List<StudyMaterial>? _studyMaterials;

  Future<void> _loadData() async {
    if (_semesters == null) {
      try {
        final String semestersJsonString = await rootBundle.loadString('assets/data/semesters.json');
        final List<dynamic> semestersJson = json.decode(semestersJsonString) as List<dynamic>;
        _semesters = semestersJson.map((jsonMap) => Semester.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Failed to load or parse semesters.json: $e');
        _semesters = [];
      }
    }

    if (_courses == null) {
      try {
        final String coursesJsonString = await rootBundle.loadString('assets/data/courses.json');
        final List<dynamic> coursesJson = json.decode(coursesJsonString) as List<dynamic>;
        // Course.fromJson was already updated in previous step, no longer expects bookIds/hasContent
        _courses = coursesJson.map((jsonMap) => Course.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Failed to load or parse courses.json: $e');
        _courses = [];
      }
    }

    // Removed loading for old books.json
    // if (_books == null) { ... }

    if (_teachers == null) {
      try {
        final String teachersJsonString = await rootBundle.loadString('assets/data/teachers.json');
        final List<dynamic> teachersJson = json.decode(teachersJsonString) as List<dynamic>;
        _teachers = teachersJson.map((jsonMap) => Teacher.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Failed to load or parse teachers.json: $e');
        _teachers = [];
      }
    }

    if (_studyMaterials == null) {
      try {
        final String materialsJsonString = await rootBundle.loadString('assets/data/studymaterials.json');
        final List<dynamic> materialsJson = json.decode(materialsJsonString) as List<dynamic>;
        _studyMaterials = materialsJson.map((jsonMap) => StudyMaterial.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Failed to load or parse studymaterials.json: $e');
        _studyMaterials = [];
      }
    }
  }

  Future<List<Semester>> getSemesters() async {
    await _loadData();
    return List.unmodifiable(_semesters ?? []);
  }

  Future<List<Course>> getCoursesForSemester(String semesterId) async {
    await _loadData();
    try {
      if (_semesters == null || _courses == null) {
         print('DataService: Semesters or courses list is null after load.');
         return List.unmodifiable([]);
      }
      final semester = _semesters!.firstWhere((sem) => sem.id == semesterId);
      return List.unmodifiable(
          _courses!.where((course) => semester.courseIds.contains(course.id)).toList());
    } catch (e) {
      print('Error finding semester with id $semesterId or filtering courses: $e');
      return List.unmodifiable([]);
    }
  }

  Future<Course?> getCourseDetails(String courseId) async {
    await _loadData();
    try {
      if (_courses == null) {
        print('DataService: Courses list is null after load for getCourseDetails.');
        return null;
      }
      return _courses!.firstWhere((course) => course.id == courseId);
    } catch (e) {
      // Don't print here as it's a common case for this method to return null
      return null;
    }
  }

  // Removed old Book-related methods:
  // Future<List<Book>> getBooksForCourse(String courseId) async { ... }
  // Future<Book?> getBookDetails(String bookId) async { ... }

  // New methods for Teachers
  Future<List<Teacher>> getTeachers() async {
    await _loadData();
    return List.unmodifiable(_teachers ?? []);
  }

  Future<Teacher?> getTeacherDetails(String teacherId) async {
    await _loadData();
    if (_teachers == null) return null;
    try {
      return _teachers!.firstWhere((teacher) => teacher.id == teacherId);
    } catch (e) {
      // print('Teacher with id $teacherId not found: $e'); // Avoid noisy logs for not found
      return null;
    }
  }

  Future<List<Teacher>> getTeachersForCourse(String courseId) async {
    await _loadData();
    if (_studyMaterials == null || _teachers == null) {
      return List.unmodifiable([]);
    }
    final teacherIdsForCourse = _studyMaterials!
        .where((material) => material.courseId == courseId && material.teacherId != null)
        .map((material) => material.teacherId!)
        .toSet();

    if (teacherIdsForCourse.isEmpty) {
      return List.unmodifiable([]);
    }

    final List<Teacher> teachers = _teachers!
        .where((teacher) => teacherIdsForCourse.contains(teacher.id))
        .toList();

    return List.unmodifiable(teachers);
  }

  // New methods for StudyMaterials
  Future<List<StudyMaterial>> getStudyMaterialsForCourse(String courseId) async {
    await _loadData();
    if (_studyMaterials == null) return List.unmodifiable([]);
    return List.unmodifiable(
        _studyMaterials!.where((material) => material.courseId == courseId).toList());
  }

  Future<List<StudyMaterial>> getStudyMaterialsForCourseByTeacher(String courseId, String teacherId) async {
    await _loadData();
    if (_studyMaterials == null) return List.unmodifiable([]);
    return List.unmodifiable(_studyMaterials!
        .where((material) => material.courseId == courseId && material.teacherId == teacherId)
        .toList());
  }

  Future<StudyMaterial?> getStudyMaterialDetails(String materialId) async {
    await _loadData();
    if (_studyMaterials == null) return null;
    try {
      return _studyMaterials!.firstWhere((material) => material.id == materialId);
    } catch (e) {
      // print('StudyMaterial with id $materialId not found: $e'); // Avoid noisy logs
      return null;
    }
  }
}
