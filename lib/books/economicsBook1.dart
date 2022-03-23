import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
class economicBooks1 extends StatelessWidget {
  const economicBooks1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();
  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: SfPdfViewer.network(
              'https://hostnezt.com/cssfiles/economics/Macroeconomics,%20Michael%20Parkin.pdf',
              controller: _pdfViewerController,
              key: _pdfViewerStateKey),
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    _pdfViewerStateKey.currentState!.openBookmarkView();
                  },
                  icon: Icon(
                    Icons.bookmark,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () {
                    _pdfViewerController.jumpToPage(5);
                  },
                  icon: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () {
                    _pdfViewerController.zoomLevel = 1.75;
                  },
                  icon: Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                  ))
            ],
          ),
        ));
  }
}
