enum StudyMaterialType { pdf, link, note }

class StudyMaterial {
  final String id;
  final String title;
  final StudyMaterialType type;
  final String path; // URL for link, asset path for PDF, or direct content for short note
  final bool isLocal; // Relevant for type 'pdf' or other potential file types
  final String courseId;
  final String? teacherId; // Nullable if it's a general course material

  StudyMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.path,
    this.isLocal = false, // Default to false, true for local PDFs/files
    required this.courseId,
    this.teacherId,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    String typeString = json['type'] as String;
    StudyMaterialType materialType;
    switch (typeString.toLowerCase()) {
      case 'pdf':
        materialType = StudyMaterialType.pdf;
        break;
      case 'link':
        materialType = StudyMaterialType.link;
        break;
      case 'note':
        materialType = StudyMaterialType.note;
        break;
      default:
        throw ArgumentError('Invalid StudyMaterialType: $typeString');
    }

    return StudyMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      type: materialType,
      path: json['path'] as String,
      isLocal: json['isLocal'] as bool? ?? false, // Default to false if null
      courseId: json['courseId'] as String,
      teacherId: json['teacherId'] as String?,
    );
  }
}
