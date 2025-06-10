import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart';
import 'package:jucse_book_house/services.dart';
import 'package:jucse_book_house/models.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // For SfPdfViewer

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Map<String, String> mockJsonAssets = {};

  setUp(() {
    mockJsonAssets.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final String assetPath = utf8.decode(message.buffer.asUint8List());
      // print("BookViewerPageTest MockAssetHandler: Request for $assetPath"); // Debug
      if (mockJsonAssets.containsKey(assetPath)) {
        // print("BookViewerPageTest MockAssetHandler: Serving $assetPath"); // Debug
        return ByteData.view(utf8.encoder.convert(mockJsonAssets[assetPath]!).buffer);
      }
      // print("BookViewerPageTest MockAssetHandler: NOT FOUND $assetPath"); // Debug
      return null; // Simulate asset not found
    });
  });

  void addMockJsonAsset(String assetPath, String jsonString) {
    mockJsonAssets[assetPath] = jsonString;
  }

  // Helper to provide a minimal valid PDF file content if needed for SfPdfViewer.asset
  // For now, SfPdfViewer.asset might not actually load content in test env if not fully rendered.
  // We are mostly checking its presence.

  group('BookViewerPage Tests', () {
    // Common setup for books.json for these tests
    const String localBookId = "local_book";
    const String localBookTitle = "Local PDF Book";
    const String localPdfPath = "assets/pdf/test_dummy.pdf"; // This actual file might not be loaded by viewer in test

    const String networkBookId = "network_book";
    const String networkBookTitle = "Network PDF Book";
    const String networkPdfUrl = "http://example.com/dummy.pdf";

    const String errorBookId = "error_book";
    const String errorBookTitle = "Error PDF Book";
    const String errorPdfPath = "assets/pdf/non_existent.pdf";


    setUp(() {
        // Provide all JSONs DataService might load, even if not directly used by the page constructor
        addMockJsonAsset('assets/data/semesters.json', '[]');
        addMockJsonAsset('assets/data/courses.json', '[]');
        addMockJsonAsset('assets/data/books.json', '''
          [
            {"id":"${localBookId}","title":"${localBookTitle}","pdfPath":"${localPdfPath}","isLocal":true},
            {"id":"${networkBookId}","title":"${networkBookTitle}","pdfPath":"${networkPdfUrl}","isLocal":false},
            {"id":"${errorBookId}","title":"${errorBookTitle}","pdfPath":"${errorPdfPath}","isLocal":true}
          ]
        ''');
        // For local asset loading, SfPdfViewer.asset might actually try to load the asset.
        // We need to mock the response for localPdfPath if it does.
        // For a real PDF, this would be ByteData of the PDF. For a test, often an empty/minimal one.
        // For now, let's add an empty string as mock content for the dummy PDF asset.
        // If SfPdfViewer has issues with empty content, this might need adjustment.
        addMockJsonAsset(localPdfPath, ""); // Mocking the PDF asset itself
    });

    testWidgets('displays loading indicator then PDF viewer for local PDF', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: BookViewerPage(bookId: localBookId, bookTitle: localBookTitle)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(); // Let FutureBuilder for book details resolve

      // Check if SfPdfViewer is in the tree
      expect(find.byType(SfPdfViewer), findsOneWidget);
      // We can't easily distinguish SfPdfViewer.asset vs .network without deeper inspection or flags.
      // Presence of the viewer is the main check here.
      // Check for cloud icon (should NOT be present for local book)
      expect(find.byIcon(Icons.cloud_outlined), findsNothing);
    });

    testWidgets('displays PDF viewer and cloud icon for network PDF', (WidgetTester tester) async {
      // SfPdfViewer.network will likely try to make a network call.
      // This might fail in test environment if not handled. For this test, we assume it renders
      // the widget before actual network loading finishes or fails, or that network calls are mocked/ignored.
      // The primary check is the UI state.

      await tester.pumpWidget(MaterialApp(home: BookViewerPage(bookId: networkBookId, bookTitle: networkBookTitle)));
      await tester.pumpAndSettle();

      expect(find.byType(SfPdfViewer), findsOneWidget);
      // Check for cloud icon (SHOULD be present for network book)
      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    });

    testWidgets('displays error message on PDF load fail', (WidgetTester tester) async {
      // The mock for errorPdfPath (non_existent.pdf) will return null via the asset handler.
      // This should trigger onDocumentLoadFailed in SfPdfViewer.asset.

      // Add a specific mock for the non-existent PDF to ensure the handler returns null for it.
      // The general handler already does this, but being explicit is fine.
      mockJsonAssets.remove(errorPdfPath); // Ensure it's treated as missing by mock handler

      await tester.pumpWidget(MaterialApp(home: BookViewerPage(bookId: errorBookId, bookTitle: errorBookTitle)));
      await tester.pumpAndSettle(); // For FutureBuilder (book details)

      // SfPdfViewer might take another frame to report load failure.
      // Pumping again, or pumpAndSettle if it involves async work in onDocumentLoadFailed.
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load PDF'), findsOneWidget);
      expect(find.byType(SfPdfViewer), findsNothing); // Viewer should not be there if error is shown
    });
  });
}
