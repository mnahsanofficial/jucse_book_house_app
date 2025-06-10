class Semester {
  final String id;
  final String name;
  final List<String> courseIds;

  Semester({required this.id, required this.name, required this.courseIds});

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] as String,
      name: json['name'] as String,
      courseIds: List<String>.from(json['courseIds'] as List<dynamic>),
    );
  }
}
