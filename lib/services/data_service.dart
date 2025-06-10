import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jucse_book_house/models.dart'; // Assuming models.dart exports all models

class DataService {
  List<Semester>? _semesters;
  List<Course>? _courses;
  List<Book>? _books;

  // Private constructor for Singleton pattern (optional, but good practice for a service)
  // DataService._internal();
  // static final DataService _instance = DataService._internal();
  // factory DataService() => _instance;
  // For simplicity now, we'll use a non-singleton version.

  Future<void> _loadData() async {
    if (_semesters == null) {
      try {
        final String semestersJsonString = await rootBundle.loadString('assets/data/semesters.json');
        final List<dynamic> semestersJson = json.decode(semestersJsonString) as List<dynamic>;
        _semesters = semestersJson.map((jsonMap) => Semester.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Failed to load or parse semesters.json: $e');
        _semesters = []; // Initialize as empty list on error
      }
    }

    if (_courses == null) {
      try {
        final String coursesJsonString = await rootBundle.loadString('assets/data/courses.json');
        final List<dynamic> coursesJson = json.decode(coursesJsonString) as List<dynamic>;
        _courses = coursesJson.map((jsonMap) => Course.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Failed to load or parse courses.json: $e');
        _courses = []; // Initialize as empty list on error
      }
    }

    if (_books == null) {
      try {
        final String booksJsonString = await rootBundle.loadString('assets/data/books.json');
        final List<dynamic> booksJson = json.decode(booksJsonString) as List<dynamic>;
        _books = booksJson.map((jsonMap) => Book.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Failed to load or parse books.json: $e');
        _books = []; // Initialize as empty list on error
      }
    }
  }

  Future<List<Semester>> getSemesters() async {
    await _loadData();
    // Ensure _semesters is not null, even if _loadData had an issue and initialized it to []
    return List.unmodifiable(_semesters ?? []);
  }

  Future<List<Course>> getCoursesForSemester(String semesterId) async {
    await _loadData();
    try {
      // Ensure _semesters and _courses are not null before proceeding
      if (_semesters == null || _courses == null) {
         print('DataService: Semesters or courses list is null after load.');
         return List.unmodifiable([]);
      }
      final semester = _semesters!.firstWhere((sem) => sem.id == semesterId);
      return List.unmodifiable(
          _courses!.where((course) => semester.courseIds.contains(course.id)).toList());
    } catch (e) {
      print('Error finding semester with id $semesterId or filtering courses: $e');
      return List.unmodifiable([]); // Return empty list
    }
  }

  Future<Course?> getCourseDetails(String courseId) async {
    await _loadData();
    try {
      // Ensure _courses is not null
      if (_courses == null) {
        print('DataService: Courses list is null after load for getCourseDetails.');
        return null;
      }
      return _courses!.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null; // Not found
    }
  }

  Future<List<Book>> getBooksForCourse(String courseId) async {
    await _loadData();
    try {
      // Ensure _courses and _books are not null
      if (_courses == null || _books == null) {
        print('DataService: Courses or books list is null after load for getBooksForCourse.');
        return List.unmodifiable([]);
      }
      final course = _courses!.firstWhere((c) => c.id == courseId);
      return List.unmodifiable(
          _books!.where((book) => course.bookIds.contains(book.id)).toList());
    } catch (e) {
      print('Error finding course with id $courseId or filtering books: $e');
      return List.unmodifiable([]); // Return empty list
    }
  }

  Future<Book?> getBookDetails(String bookId) async {
    await _loadData();
     try {
       // Ensure _books is not null
      if (_books == null) {
        print('DataService: Books list is null after load for getBookDetails.');
        return null;
      }
      return _books!.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null; // Not found
    }
  }
}
