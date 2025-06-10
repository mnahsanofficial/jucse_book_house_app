class Book {
  final String id;
  final String title;
  final String pdfPath;
  final bool isLocal;

  Book({required this.id, required this.title, required this.pdfPath, required this.isLocal});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      pdfPath: json['pdfPath'] as String,
      isLocal: json['isLocal'] as bool,
    );
  }
}
