import 'package:flutter/material.dart';
import 'package:jucse_book_house/models.dart';
import 'package:jucse_book_house/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudyMaterialViewerPage extends StatefulWidget {
  final String materialId;
  final String materialTitle;

  const StudyMaterialViewerPage({
    Key? key,
    required this.materialId,
    required this.materialTitle,
  }) : super(key: key);

  @override
  _StudyMaterialViewerPageState createState() => _StudyMaterialViewerPageState();
}

class _StudyMaterialViewerPageState extends State<StudyMaterialViewerPage> {
  late Future<StudyMaterial?> _materialFuture;
  final DataService _dataService = DataService();

  PdfViewerController? _pdfViewerController;
  GlobalKey<SfPdfViewerState>? _pdfViewerStateKey;
  String? _pdfLoadingError;
  StudyMaterial? _currentMaterial;

  @override
  void initState() {
    super.initState();
    _materialFuture = _dataService.getStudyMaterialDetails(widget.materialId);
    _materialFuture.then((material) {
      if (material != null && material.type == StudyMaterialType.pdf) {
        if (mounted) { // Ensure widget is still mounted before calling setState
          setState(() {
            _pdfViewerController = PdfViewerController();
            _pdfViewerStateKey = GlobalKey<SfPdfViewerState>();
            _currentMaterial = material;
          });
        }
      } else if (material != null) {
         if (mounted) {
            setState(() {
              _currentMaterial = material; // For non-PDF types, AppBar actions won't be shown
            });
         }
      }
    });
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Log error or show a more specific message if desired
      print('Could not launch $urlString');
      if (mounted) { // Ensure widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch URL: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materialTitle),
        actions: (_currentMaterial != null && _currentMaterial!.type == StudyMaterialType.pdf && _pdfViewerController != null && _pdfViewerStateKey != null)
          ? <Widget>[
              IconButton(
                  onPressed: () {
                    if (_pdfViewerStateKey?.currentState != null) {
                      _pdfViewerStateKey!.currentState!.openBookmarkView();
                    }
                  },
                  icon: Icon(Icons.bookmark, color: Colors.white)),
              IconButton(
                  onPressed: () => _pdfViewerController?.jumpToPage(5),
                  icon: Icon(Icons.arrow_drop_down_circle, color: Colors.white)),
              IconButton(
                  onPressed: () {
                    if (_pdfViewerController?.zoomLevel == 1.0) {
                       _pdfViewerController?.zoomLevel = 1.5;
                    } else if (_pdfViewerController?.zoomLevel == 1.5) {
                       _pdfViewerController?.zoomLevel = 2.0;
                    } else {
                       _pdfViewerController?.zoomLevel = 1.0;
                    }
                  },
                  icon: Icon(Icons.zoom_in, color: Colors.white)),
            ]
          : null,
      ),
      body: FutureBuilder<StudyMaterial?>(
        future: _materialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Error: Could not load study material details.'));
          }

          final material = snapshot.data!;

          if (material.type == StudyMaterialType.pdf) {
            if (_pdfLoadingError != null) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading PDF: $_pdfLoadingError', textAlign: TextAlign.center),
              ));
            }
            if (_pdfViewerController == null || _pdfViewerStateKey == null) {
                return Center(child: Text('Initializing PDF viewer...'));
            }

            Widget pdfViewerWidget;
            if (material.isLocal) {
                pdfViewerWidget = SfPdfViewer.asset(
                    material.path,
                    controller: _pdfViewerController!,
                    key: _pdfViewerStateKey!,
                    onDocumentLoadFailed: (details) { if(mounted) setState(() => _pdfLoadingError = details.description);},
                );
            } else {
                pdfViewerWidget = SfPdfViewer.network(
                    material.path,
                    controller: _pdfViewerController!,
                    key: _pdfViewerStateKey!,
                    onDocumentLoadFailed: (details) { if(mounted) setState(() => _pdfLoadingError = details.description);},
                );
            }
            return pdfViewerWidget;

          } else if (material.type == StudyMaterialType.link) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('This is a web link. Click below to open.', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.open_in_browser),
                      label: Text('Open Link'),
                      onPressed: () => _launchURL(material.path),
                    ),
                    SizedBox(height: 10),
                    Text(material.path, style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          } else if (material.type == StudyMaterialType.note) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(material.path, style: TextStyle(fontSize: 16)),
            );
          } else {
            return Center(child: Text('Unsupported study material type.'));
          }
        },
      ),
    );
  }
}
