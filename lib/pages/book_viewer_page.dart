import 'package:flutter/material.dart';
import 'package:jucse_book_house/models.dart';
import 'package:jucse_book_house/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookViewerPage extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const BookViewerPage({
    Key? key,
    required this.bookId,
    required this.bookTitle,
  }) : super(key: key);

  @override
  _BookViewerPageState createState() => _BookViewerPageState();
}

class _BookViewerPageState extends State<BookViewerPage> {
  late Future<Book?> _bookFuture;
  final DataService _dataService = DataService();
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  String? _pdfLoadingError;
  Book? _currentBook;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _bookFuture = _dataService.getBookDetails(widget.bookId).then((book) {
      if (mounted) { // Ensure widget is still in the tree
        setState(() {
          _currentBook = book;
        });
      }
      return book;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(widget.bookTitle, overflow: TextOverflow.ellipsis)),
            if (_currentBook != null && !_currentBook!.isLocal) ...[
              SizedBox(width: 8),
              Icon(Icons.cloud_outlined, size: 20, color: Colors.white), // Added color for visibility
            ]
          ],
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                if (_pdfViewerStateKey.currentState != null) {
                  _pdfViewerStateKey.currentState!.openBookmarkView();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF Viewer not ready for bookmarks.')),
                  );
                }
              },
              icon: Icon(Icons.bookmark, color: Colors.white)),
          IconButton(
              onPressed: () {
                _pdfViewerController.jumpToPage(5); // Example page
              },
              icon: Icon(Icons.arrow_drop_down_circle, color: Colors.white)),
          IconButton(
              onPressed: () {
                if (_pdfViewerController.zoomLevel == 1.0) {
                  _pdfViewerController.zoomLevel = 1.5;
                } else if (_pdfViewerController.zoomLevel == 1.5) {
                   _pdfViewerController.zoomLevel = 2.0;
                } else {
                  _pdfViewerController.zoomLevel = 1.0;
                }
              },
              icon: Icon(Icons.zoom_in, color: Colors.white)),
        ],
      ),
      body: Builder( // Use Builder to ensure context for ScaffoldMessenger is correct
        builder: (BuildContext scaffoldContext) {
          if (_pdfLoadingError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_pdfLoadingError!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 16)),
              )
            );
          }

          return FutureBuilder<Book?>(
            future: _bookFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _currentBook == null) { // Show loader only if _currentBook is not yet set
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading book details: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                // This case might be hit if _bookFuture completes with null before error or data
                if (_pdfLoadingError == null) { // Avoid showing this if a PDF load error is already displayed
                   return Center(child: Text('Book details not found.'));
                } else {
                  // Error is already displayed by the outer check
                  return SizedBox.shrink();
                }
              }

              // _currentBook should be set by now if data is loaded
              final book = _currentBook!; // Use the state variable _currentBook

              // If a PDF loading error occurred for this specific book, display it.
              // This check is somewhat redundant if the outer check for _pdfLoadingError is comprehensive,
              // but kept for clarity in case of specific timing issues.
              if (_pdfLoadingError != null) {
                 return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_pdfLoadingError!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 16)),
                  )
                );
              }

              Widget pdfViewer;
              final pdfLoadFailedCallback = (PdfDocumentLoadFailedDetails details) {
                if (mounted) {
                  setState(() {
                    _pdfLoadingError = 'Failed to load PDF: ${details.error}\n${details.description}';
                  });
                }
                print('PDF Load Error: ${details.error}');
                print('PDF Load Description: ${details.description}');
              };

              if (book.isLocal) {
                pdfViewer = SfPdfViewer.asset(
                  book.pdfPath,
                  controller: _pdfViewerController,
                  key: _pdfViewerStateKey,
                  onDocumentLoadFailed: pdfLoadFailedCallback,
                );
              } else {
                pdfViewer = SfPdfViewer.network(
                  book.pdfPath,
                  controller: _pdfViewerController,
                  key: _pdfViewerStateKey,
                  onDocumentLoadFailed: pdfLoadFailedCallback,
                );
              }

              return pdfViewer; // Removed WillPopScope as it's not strictly necessary for controller disposal. SfPdfViewer handles its controller.
            },
          );
        }
      ),
    );
  }
}
