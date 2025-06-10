class Course {
  final String id;
  final String title;
  final String semesterId;

  Course({
    required this.id,
    required this.title,
    required this.semesterId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      semesterId: json['semesterId'] as String,
    );
  }
}
