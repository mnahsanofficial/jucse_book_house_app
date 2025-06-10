class Course {
  final String id;
  final String title;
  final String semesterId;
  final List<String> bookIds;
  final bool hasContent;

  Course({
    required this.id,
    required this.title,
    required this.semesterId,
    required this.bookIds,
    required this.hasContent,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      semesterId: json['semesterId'] as String,
      bookIds: List<String>.from(json['bookIds'] as List<dynamic>),
      hasContent: json['hasContent'] as bool,
    );
  }
}
