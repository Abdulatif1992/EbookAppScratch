import 'package:flutter/material.dart';
import 'dart:convert';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

//my files
import 'package:ebook_app_scratch/utils/database_helper.dart';
import 'package:ebook_app_scratch/models/book_from_sql.dart';
import 'package:ebook_app_scratch/constants/constants.dart';
import 'package:ebook_app_scratch/home_screen.dart';
import 'package:ebook_app_scratch/authentication/login_page.dart';
import 'package:ebook_app_scratch/screens/pdfreader_screen.dart';
import 'package:ebook_app_scratch/models/book.dart';

// animated icon
import 'package:animated_icon/animated_icon.dart';

// get
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//it is for zip
import 'package:archive/archive.dart';

// my packages
import 'package:epub_reader_make_pages/epub_reader_make_pages.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.book});

  final BookFromSql book;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  bool isDownloadStarted = false;
  bool isDownloadFinish = false;

  final box = GetStorage();  

  @override
  void initState(){
    _checkDownload(widget.book.bookid);
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
               elevation: 0.0,
        leading: _appBarBack(),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Center(
                    child: Image.memory(
                        base64Decode('${widget.book.base64}'),
                        height: 200.0,
                        width: 160.0,   
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5.0),
                    width: screenWidth-200.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.book.bookname, 
                        style: const TextStyle(fontSize: 22, color: Colors.blueGrey),),
                        Visibility(
                          visible: !isDownloadFinish,
                          child: _visible()
                        ),
                        Visibility(
                          visible: isDownloadFinish,
                          child: ElevatedButton(onPressed: () async{
                              await unzipEpub(widget.book.bookid); 
                            }, 
                            child: const Text("     Open   "),
                          ),
                        ),                                 
                      ],
                    ),
                  ),
                ],
              ),              
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: const Text("Book Description",
                      style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.black),
                  Container(height: screenHeight*0.45,
                    //color: Colors.green, 
                    child: Text(widget.book.booktitle,
                      style: const TextStyle(fontSize: 16),
                  ),),
                  
                ],
              ),
            ],
          ),
        ),
      ), 
    );
  }

  Widget _visible(){
    if(isDownloadStarted){
      return AnimateIcon(
          key: UniqueKey(),
          onTap: () {},
          iconType: IconType.continueAnimation,
          height: 70,
          width: 70,                                   
          animateIcon: AnimateIcons.iPhoneSpinner,
          color: Colors.blue,
      );
    }
    else{
      return ElevatedButton(onPressed: () {_download(widget.book.bookid);}, child: const Text("Download"));
    }
  }

  Widget _appBarBack(){
    if(isDownloadFinish){
      return IconButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        icon: const Icon(Icons.arrow_back, color: Colors.blue,),
      );
    }
    else{
      return IconButton(
          onPressed: () {
            Navigator.pop(
              context, 
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.blue,),
        );
    }
  }

  Future<void> _download(int bookId) async {

    setState(() {
        isDownloadFinish = false;
        isDownloadStarted = true;        
      });  
    
    String filePath = await downloadFile(
        '${siteUrl}download/$bookId', '$bookId','$bookId.zip');

    if(filePath=='Unauthenticated')
    {
      Get.to(() => const LoginPage());
    }
    else if(filePath=='Error')
    {
      Get.snackbar(
          'Error',
          'Something is wrong please try again',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
    }
    else if(filePath=='This is a paid book')
    {
      Get.snackbar(
          'Error',
          'This is a paid book',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isDownloadFinish = true;
        setState(() {
          isDownloadFinish = isDownloadFinish;
        });
      //print('This is a paid book');

    }
    else{
      await updateDb(bookId);
      await _checkDownload(bookId);
      //print('Fayl yuklandi: $filePath');
    }
  }

  Future<String> downloadFile(String url, String foulder, String filename) async {   
    final token = box.read('token');

    var request = await http.get(
      Uri.parse(url), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }
      );
    if(request.statusCode==200)
    {
      // create unique foulder
      var dir = (await getApplicationDocumentsDirectory()).path;
      await createFolder(dir, foulder);

      var bytes = request.bodyBytes;
      File file = File('$dir/$foulder/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    }
    else{
      if(json.decode(request.body)['message']=='Unauthenticated.') {return 'Unauthenticated';}
      else if(json.decode(request.body)['message']=='This is a paid book'){return 'This is a paid book';}
      else {return 'Error';}
    }
    
  }

  Future<void> updateDb(int bookId) async{
    String dir = (await getApplicationDocumentsDirectory()).path;

    String bookUrl = "$dir/$bookId/$bookId.zip";
    if(await File(bookUrl).exists()==true)
    {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      await databaseHelper.updateBookUpd(bookId);
      await databaseHelper.updateBookDtime(bookId, timestamp);
    }
    else{}
  }

  Future<void> _checkDownload(int bookId) async{
    String dir = (await getApplicationDocumentsDirectory()).path;

    String bookUrl = "$dir/$bookId/$bookId.zip";

    if(widget.book.upd==1){
      isDownloadFinish = true;
      setState(() {
        isDownloadFinish = isDownloadFinish;
      });
    }
    else if(await File(bookUrl).exists()==true){
      isDownloadFinish = true;
        setState(() {
          isDownloadFinish = isDownloadFinish;
          isDownloadStarted = false;
        });

      
    }
  }

  Future<void>unzipEpub(int bookid) async{
    String dir = (await getApplicationDocumentsDirectory()).path;

    String bookUrl = "$dir/$bookid/$bookid.zip";
    if(await File(bookUrl).exists()==true)
    {
      
      // Read the Zip file from disk.
      var bytes = File(bookUrl).readAsBytesSync();

      // Decode the Zip file
      final archive = ZipDecoder().decodeBytes(
        bytes,
        verify: true,
        password: "sazagan_92",
        );

      // Extract the contents of the Zip archive to disk.
      String extention = "";
      String pdfUrl = "";
      for (var file in archive) {
        String fullName = file.name;
        extention = fullName.substring(fullName.indexOf('.'));

        var fileName = '$dir/$bookid/$bookid$extention';
        pdfUrl = fileName;
        if (file.isFile) {
          var outFile = File(fileName);
          //print('File::' + outFile.path);
          //_tempImages.add(outFile.path);
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        }
      }
      if(extention=='.epub')
      {
        BuildContext currentContext = context;
        GetListFromEpub getList = GetListFromEpub(name:'$bookid$extention', folder: '$bookid');
        var htmlAndTitle = await getList.parseEpubWithChapters(); 
        List<String> htmlList =    htmlAndTitle.item1;          
        String fullHtml = htmlList.last;
        htmlList.length = htmlList.length-1;  
        List<BookTitle> titles = htmlAndTitle.item2;

        int page = 0;
        double location = 0.0;

        bool checker = await SessionManager().containsKey("$bookid");
        if(checker)
        {
          HtmlBook book  = HtmlBook.fromJson( await SessionManager().get("$bookid"));
          page = book.page!;
          location = book.location;
        }

        if (!currentContext.mounted) return;
        await Navigator.of(currentContext).push(MaterialPageRoute(
          builder: (context) => ScrollBarExp3(
            bookId: "$bookid",
            data: htmlList,
            page: page,
            location: location,
            fullHtml: fullHtml,
            titles: titles,
          ),
        ));       
      }
      else
      {
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        await DatabaseHelper().updateBookDtime(bookid, timestamp);
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => PdfReaderScreen(bookId: bookid, pdfUrl: pdfUrl)),          
        );
      }
    }
    else{
      //print("zip file is not exist");
    }
  }

  Future<void> createFolder(String path, String folderName) async {
  // Create a Directory instance at the specified path
  Directory newFolder = Directory('$path/$folderName');

  // Check if the folder already exists
  if (await newFolder.exists()) {
    //print('Folder already exists');
  } else {
    // Create the folder
    await newFolder.create();
    //print('Folder created at $path/$folderName');
  }
}
}

