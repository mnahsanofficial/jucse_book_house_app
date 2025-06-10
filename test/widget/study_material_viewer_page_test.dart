import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jucse_book_house/pages.dart'; // Imports StudyMaterialViewerPage
import 'package:jucse_book_house/services.dart'; // Imports DataService
import 'package:jucse_book_house/models.dart';   // Imports StudyMaterial, StudyMaterialType
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // For SfPdfViewer

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Map<String, String> mockJsonAssets = {};

  // --- Mock JSON String Constants ---
  const String localPdfAssetPath = "assets/pdf/dummy_local.pdf";
  const String nonExistentAssetPath = "assets/pdf/non_existent.pdf";

  const String mockStudyMaterialsForViewer = '''
  [
    {"id":"pdf_local","title":"Local PDF","type":"pdf","path":"${localPdfAssetPath}","isLocal":true,"courseId":"c1"},
    {"id":"pdf_network","title":"Network PDF","type":"pdf","path":"http://example.com/network.pdf","isLocal":false,"courseId":"c1"},
    {"id":"link_ext","title":"External Link","type":"link","path":"http://example.com/external","isLocal":false,"courseId":"c1"},
    {"id":"note_simple","title":"Simple Note","type":"note","path":"This is a test note.","isLocal":false,"courseId":"c1"},
    {"id":"pdf_error_local","title":"Local PDF Error","type":"pdf","path":"${nonExistentAssetPath}","isLocal":true,"courseId":"c1"}
  ]
  ''';

  setUpAll(() {
    // This mock handler is set up once for all tests in this file.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final String assetPath = utf8.decode(message.buffer.asUint8List());
      // print("StudyMaterialViewerTest MockAssetHandler: Request for $assetPath"); // Debug
      if (mockJsonAssets.containsKey(assetPath)) {
        // print("StudyMaterialViewerTest MockAssetHandler: Serving $assetPath"); // Debug
        return ByteData.view(utf8.encoder.convert(mockJsonAssets[assetPath]!).buffer);
      }
      // print("StudyMaterialViewerTest MockAssetHandler: NOT FOUND $assetPath"); // Debug
      return null; // Simulate asset not found
    });
  });

  setUp(() {
    mockJsonAssets.clear();
    // Base JSONs needed for DataService to load without issues, even if not directly used by a test
    addMockJsonAsset('assets/data/semesters.json', '[]');
    addMockJsonAsset('assets/data/courses.json', '[]');
    addMockJsonAsset('assets/data/teachers.json', '[]');
    addMockJsonAsset('assets/data/studymaterials.json', mockStudyMaterialsForViewer);

    // Mock the content of the local PDF asset that IS expected to load
    addMockJsonAsset(localPdfAssetPath, "%PDF-1.4\n%âãÏÓ\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R >>\nendobj\n4 0 obj\n<< /Length 36 >>\nstream\nBT\n/F1 24 Tf\n100 700 Td\n(Minimal PDF) Tj\nET\nendstream\nendobj\nxref\n0 5\n0000000000 65535 f \n0000000015 00000 n \n0000000064 00000 n \n0000000123 00000 n \n0000000220 00000 n \ntrailer\n<< /Size 5 /Root 1 0 R >>\nstartxref\n279\n%%EOF");
    // nonExistentAssetPath does not get an entry in mockJsonAssets, so it will return null (not found)
  });


  void addMockJsonAsset(String assetPath, String jsonString) {
    mockJsonAssets[assetPath] = jsonString;
  }

  group('StudyMaterialViewerPage Tests', () {
    testWidgets('displays PDF viewer for local PDF material', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: StudyMaterialViewerPage(materialId: "pdf_local", materialTitle: "Local PDF")));
      await tester.pumpAndSettle(); // For FutureBuilder (material details) & PDF load

      expect(find.byType(SfPdfViewer), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget); // Check for PDF controls
    });

    testWidgets('displays PDF viewer for network PDF material', (WidgetTester tester) async {
      // SfPdfViewer.network might issue a network request. This test primarily checks widget presence.
      // Actual network fetching is hard to test without more complex mocking.
      await tester.pumpWidget(MaterialApp(home: StudyMaterialViewerPage(materialId: "pdf_network", materialTitle: "Network PDF")));
      await tester.pumpAndSettle();

      expect(find.byType(SfPdfViewer), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget); // PDF controls
    });

    testWidgets('displays link button for link material and handles tap (shows SnackBar)', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: StudyMaterialViewerPage(materialId: "link_ext", materialTitle: "External Link")));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Open Link'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Open Link'));
      await tester.pumpAndSettle(); // For SnackBar display

      // Expect the SnackBar due to url_launcher not working in test environment by default
      expect(find.textContaining('Link functionality requires url_launcher'), findsOneWidget);
    });

    testWidgets('displays note content for note material', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: StudyMaterialViewerPage(materialId: "note_simple", materialTitle: "Simple Note")));
      await tester.pumpAndSettle();

      expect(find.text("This is a test note."), findsOneWidget);
    });

    testWidgets('displays error if material details fail to load', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: StudyMaterialViewerPage(materialId: "non_existent_material", materialTitle: "Non Existent")));
      await tester.pumpAndSettle();

      expect(find.text('Error: Could not load study material details.'), findsOneWidget);
    });

    testWidgets('displays error if local PDF document fails to load', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: StudyMaterialViewerPage(materialId: "pdf_error_local", materialTitle: "Local PDF Error")));

      // Multiple pumps might be needed:
      // 1. For FutureBuilder to resolve StudyMaterial.
      // 2. For SfPdfViewer.asset to attempt loading and call onDocumentLoadFailed.
      // 3. For setState in onDocumentLoadFailed to rebuild with the error.
      await tester.pumpAndSettle(); // Resolves Future, SfPdfViewer.asset starts loading
      await tester.pumpAndSettle(); // Allows async onDocumentLoadFailed & subsequent setState to complete

      expect(find.textContaining('Failed to load PDF'), findsOneWidget);
      expect(find.byType(SfPdfViewer), findsNothing); // Viewer should not be shown
    });
  });
}
