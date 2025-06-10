import 'package:flutter/material.dart';
import 'package:jucse_book_house/models.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/pages.dart'; // Added import for StudyMaterialViewerPage

class CourseMaterialsPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseMaterialsPage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  _CourseMaterialsPageState createState() => _CourseMaterialsPageState();
}

class _CourseMaterialsPageState extends State<CourseMaterialsPage> {
  late DataService _dataService;
  List<StudyMaterial>? _allMaterials;
  List<Teacher>? _courseTeachers;
  final Map<String?, List<StudyMaterial>> _groupedMaterials = {}; // Key: teacherId (String) or null for general
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataService = DataService();
    _fetchCourseData();
  }

  Future<void> _fetchCourseData() async {
    setState(() {
      _isLoading = true;
    });

    _allMaterials = await _dataService.getStudyMaterialsForCourse(widget.courseId);
    // Fetch all teachers to map names later, or getTeachersForCourse could return Teacher objects directly
    _courseTeachers = await _dataService.getTeachersForCourse(widget.courseId);

    _groupMaterials();

    setState(() {
      _isLoading = false;
    });
  }

  void _groupMaterials() {
    _groupedMaterials.clear();
    if (_allMaterials == null) return;

    // Group general materials (teacherId is null)
    _groupedMaterials[null] = _allMaterials!.where((m) => m.teacherId == null).toList();

    // Group materials by teacher
    if (_courseTeachers != null) {
      for (var teacher in _courseTeachers!) {
        _groupedMaterials[teacher.id] = _allMaterials!
            .where((m) => m.teacherId == teacher.id)
            .toList();
      }
    }
  }

  Widget _buildMaterialListTile(StudyMaterial material) {
    IconData iconData;
    switch (material.type) {
      case StudyMaterialType.pdf:
        iconData = Icons.picture_as_pdf_outlined;
        break;
      case StudyMaterialType.link:
        iconData = Icons.link_outlined;
        break;
      case StudyMaterialType.note:
        iconData = Icons.note_outlined;
        break;
      default:
        iconData = Icons.article_outlined;
    }

    return ListTile(
      leading: Icon(iconData),
      title: Text(material.title),
      // Subtitle could show teacher if not already in an ExpansionTile header
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyMaterialViewerPage(
              materialId: material.id,
              materialTitle: material.title,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _allMaterials == null || _allMaterials!.isEmpty
              ? Center(child: Text('No study materials found for this course.'))
              : ListView(
                  children: _buildExpansionTiles(),
                ),
    );
  }

  List<Widget> _buildExpansionTiles() {
    final List<Widget> tiles = [];

    // General Materials
    final generalMaterials = _groupedMaterials[null];
    if (generalMaterials != null && generalMaterials.isNotEmpty) {
      tiles.add(
        ExpansionTile(
          title: Text('General Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          initiallyExpanded: true,
          children: generalMaterials.map(_buildMaterialListTile).toList(),
        ),
      );
    }

    // Materials by Teacher
    if (_courseTeachers != null) {
      for (var teacher in _courseTeachers!) {
        final teacherMaterials = _groupedMaterials[teacher.id];
        if (teacherMaterials != null && teacherMaterials.isNotEmpty) {
          tiles.add(
            ExpansionTile(
              title: Text(teacher.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              initiallyExpanded: true, // Or based on some logic
              children: teacherMaterials.map(_buildMaterialListTile).toList(),
            ),
          );
        }
      }
    }

    if (tiles.isEmpty && (_allMaterials != null && _allMaterials!.isNotEmpty) ) {
        // This case might happen if all materials have teacherIds not in _courseTeachers (data inconsistency)
        // Or if _courseTeachers is empty but materials have teacherIds.
        // For now, just show all materials ungrouped if no tiles were created but materials exist.
        tiles.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Available Materials:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
        ));
        tiles.addAll(_allMaterials!.map(_buildMaterialListTile).toList());
    }


    return tiles;
  }
}
