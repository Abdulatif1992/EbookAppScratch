import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

// it is for pdf books
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:ebook_app_scratch/models/book.dart';
import 'package:ebook_app_scratch/home_screen.dart';

//it is for File
import 'dart:io';
//it is for zip
//import 'package:archive/archive.dart';
// it is for getting path
//import 'package:path_provider/path_provider.dart';

class PdfReaderScreen extends StatefulWidget {
  const PdfReaderScreen({super.key, required this.bookId, required this.pdfUrl});

  final int bookId;
  final String pdfUrl;

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {

  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState(){   
    _pdfViewerController = PdfViewerController();
    getSession();
    super.initState();
  }

  void getSession() async {
    int bookId = widget.bookId;
    dynamic book = await SessionManager().get("$bookId");
    //User u = User.fromJson(await SessionManager().get("user"));
    if (book != null) {
      _pdfViewerController.jumpToPage(book['page']);

      // int page = book['page'];
      // print("key bor $book page raqami esa $page");
    } else {
      // print("key yo'q bu kitobda");
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
               elevation: 0.0,
        leading: _appBarBack(context),       
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.article_outlined,
              color: Colors.blue,
            ),
            onPressed: () {_pdfViewerKey.currentState?.openBookmarkView();},
          ),
          IconButton(
            icon: const Icon(
              Icons.zoom_in,
              color: Colors.blue,
            ),
            onPressed: () {_pdfViewerController.zoomLevel = 1.2;},
          ),
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_up,
              color: Colors.blue,
            ),
            onPressed: () {_pdfViewerController.previousPage();},
          ),
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.blue,
            ),
            onPressed: () {_pdfViewerController.nextPage();},
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.blue,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        child: SfPdfViewer.file(
              File(widget.pdfUrl),
              pageLayoutMode: PdfPageLayoutMode.single,
              pageSpacing: 0,
              controller: _pdfViewerController,
             ),
      ),
    );
  }

    Widget _appBarBack(BuildContext context){
    return IconButton(
      onPressed: () {
        var page = _pdfViewerController.pageNumber;
        PdfBook book = PdfBook(bookId: '${widget.bookId}',bookUrl: widget.pdfUrl, page: page);        
        SessionManager().set("${widget.bookId}", book);   

        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      icon: const Icon(Icons.arrow_back, color: Colors.blue,),
    );    
  }

}



