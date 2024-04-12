import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// it is for checking internet connection
import 'package:internet_connection_checker/internet_connection_checker.dart';
//it is for http
import 'package:http/http.dart' as http;
import 'dart:convert'; // it is for jsonDecode
import 'package:get/get.dart'; // it is for Get 
//it is for tuple function
import 'package:tuple/tuple.dart';

// my files
import 'package:ebook_app_scratch/utils/database_helper.dart';
import 'package:ebook_app_scratch/utils/database_helper_category.dart';
import 'package:ebook_app_scratch/models/book_from_sql.dart';
import 'package:ebook_app_scratch/models/category_from_sql.dart';
import 'package:ebook_app_scratch/constants/constants.dart';
import 'package:ebook_app_scratch/screens/category_screen.dart';
import 'package:ebook_app_scratch/screens/detail_screen.dart';


import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:ebook_app_scratch/models/book.dart';


//my files

import 'package:ebook_app_scratch/screens/pdfreader_screen.dart';

//it is for zip
import 'package:archive/archive.dart';

// my packages
import 'package:epub_reader_make_pages/epub_reader_make_pages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  

  var bookList = List<BookFromSql>.empty();
  var bookListDownloaded = List<BookFromSql>.empty();
  var categoryList = List<CategoryFromSql>.empty();

  var _foundBook = List<BookFromSql>.empty();

  bool isloading = true;

  @override
  void initState(){
    _foundBook = bookList;
    _getData();
    checkInternet();
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          child: bookList.isEmpty
          ? _listIsempty()
          :
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _firstTitle(),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(50, 171, 207, 240),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: bookListDownloaded.map((book) => InkWell(
                        onTap: () async{
                          await unzipEpub(book.bookid); 
                        },
                        child: _myBooks(book.bookid, book.base64),
                      )).toList(),
                    ),
                  ),
                ),

                _categoriesTitle(),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    //color: Colors.pink,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(50, 171, 207, 240),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: categoryList.map((category) => InkWell(   
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => CategoryScreen(catId: category.id, catName: category.categoryName)),
                          );
                        },                     
                        child: _myCategories(category.categoryName),
                      )).toList(),                   
                    ),
                  ),
                ),

                TextField(
                  onChanged: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                    labelText: 'Search', suffixIcon: Icon(Icons.search)
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await checkInternet();                    
                    }, 
                  child: const Text('Refresh', style: TextStyle(fontSize: 18)),
                ), 

                _titleFromInternet(),

                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: _foundBook.map((book) => InkWell(
                      child: _allBooks(book),
                    )).toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // widgets
  Widget _listIsempty(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: !isloading,
          child: GestureDetector(
            child: Center(
              child: Container(
                //color: Colors.red,
                width:  100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black,
                  image: const DecorationImage(
                    image:AssetImage("assets/img/restart2.jpg"), 
                    fit:BoxFit.cover
                  ), // button text
                )
              ),                
            ),
            onTap:(){
            setState(() {
              isloading = true;
            });  
            checkInternet();
            }
          ),
        ),
        Visibility(
          visible: isloading,
          child: const Center(
            child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
          )
          ),
      ],
    );
  }

  Widget _firstTitle(){
    try {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 12.0),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book,
              color: Colors.blueGrey,
              size: 26.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'My books',
                style: GoogleFonts.roboto(
                  fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.blueGrey
                ),
              ),
            ),
          ],
        ),
      );
    } on Exception catch (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book,
              color: Colors.black,
              size: 36.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'My books',
                style: GoogleFonts.roboto(
                  fontSize: 28.0, fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      );
    }    
  }

  Widget _myBooks(int bookId, String base64){
    try{
      return Container(
        margin: const EdgeInsets.all(5),
        height: 200,
        width: 160,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
                base64Decode("$base64"),
                height: 200.0,
                width: 160.0,   
            ),
        )
      );
    }
    on Exception catch (_) {
      updateBook(bookId);
      return Container(
        margin: const EdgeInsets.all(5),
        height: 200,
        width: 160,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset('assets/img/No_image.png',
                height: 200.0,
                width: 160.0,   
            ),
        )
      );
    }
  }

  Widget _categoriesTitle(){
    try {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 12.0),
        child: Row(
          children: [
            const Icon(
              Icons.article_outlined,
              color: Colors.blueGrey,
              size: 26.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'Categories',
                style: GoogleFonts.roboto(
                  fontSize: 22.0, fontWeight: FontWeight.normal, color: Colors.blueGrey
                ),
              ),
            ),
          ],
        ),
      );
    } on Exception catch (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book,
              color: Colors.black,
              size: 36.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'Categories',
                style: GoogleFonts.roboto(
                  fontSize: 28.0, fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      );
    }    
  }
  
  Widget _myCategories(String catName){    
    return Container(
      margin: const EdgeInsets.all(8),
      height: 25.0,
      child: ClipRRect(        
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            //margin: EdgeInsets.all(2.0),
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
            color: Colors.lightBlue,
            child: Text(
              catName,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600, // light
                fontStyle: FontStyle.italic, // italic
              ),
            ),
          ),
      ),      
    );
  }
  
  Widget _titleFromInternet(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Icon(
            Icons.file_download_sharp,
            color: Colors.blueGrey,
            size: 26.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'All books',
              style: GoogleFonts.roboto(
                fontSize: 22.0, fontWeight: FontWeight.normal, color: Colors.blueGrey
              ),
            ),
          ),
        ],
      ),
    );
  }
    
  Widget _allBooks(BookFromSql book){
    try{
      return Container(
        //color: Colors.pink,
        margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        height: 150.0,
        decoration: BoxDecoration(
          color: const Color.fromARGB(50, 171, 207, 240),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _imgBase64(book.bookid ,book.base64),            
            _detail(book),
            _detailIcon(book.upd, book.booktype),
          ],
        ),
      );
    }
    on Exception catch(_){
      return Container(
        //color: Colors.pink,        
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 171, 207, 240),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children:  [
            Text("Something is wrong")
          ],
        ),
      );
    }
  }

  Widget _imgBase64(int bookId, String base64){
    try{
      return Container(
        margin: const EdgeInsets.all(5),
        height: 150,
        width: 120,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.memory(
                base64Decode("$base64"),
                height: 150.0,
                width: 120.0,   
            ),
        )
      );
    }
    on Exception catch (_) {
      updateBook(bookId);
      return Container(
        margin: const EdgeInsets.all(5),
        height: 150,
        width: 120,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset('assets/img/No_image.png',
                height: 150.0,
                width: 120.0,   
            ),
        )
      );
    }
  }

  Widget _detail(BookFromSql book){
    double screenWidth = MediaQuery.of(context).size.width;
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(top: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.bookname, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),),
            Container(width: screenWidth-200.0, height: 60.0,child: Text(book.booktitle)),
            TextButton.icon(
              onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => DetailScreen(book: book)),
                  );
              },
              icon: const Icon(Icons.file_open, size: 16),
              label: const Text("detail", style: TextStyle(fontSize: 18.0),),
            )            
          ],
        ),
      ),
    );
  }

  Widget _detailIcon(int upd, String btype){
    if(upd==1){
      return Container(
      width: 30.0,
      height: 80.0,
      decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(width: 1.5, color: Colors.grey),
            ),
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          btype=="pdf"? Text(btype):const Text(''),
          const Icon(Icons.done_all, color: Colors.green,),
        ],
      ),
    );
    }
    else{
      return Container(
      width: 30.0,
      height: 80.0,
      decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(width: 1.5, color: Colors.grey),
            ),
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          btype=="pdf"? Text(btype):const Text(''),
          const Icon(Icons.file_download, color: Colors.red,),
        ],
      ),
    );
    }
  }


  // functions
  Future<void> _getData() async {
    bookList = await databaseHelper.getBookList();
    bookListDownloaded = await databaseHelper.getBookListDowloaded();
    categoryList = await databaseHelperCategory.getCategoryList();
    setState(() {
      categoryList = categoryList;
      bookList = bookList;
      bookListDownloaded = bookListDownloaded;  
      _foundBook = bookList;  
    });
  }

  Future<void> checkInternet() async {
    bool check = await InternetConnectionChecker().hasConnection;
    if (check) {
      List oldCats = await databaseHelperCategory.getCategoryList();
      List oldCatsId = [0];
      for (var i = 0; i < oldCats.length; i++) {
        oldCatsId.add(oldCats[i].id);
      }      
      await getCategories(oldCatsId);  
      var booksId = await getBooksId();     
      if (booksId.item2 == null) {
        List oldBooksId = [];
        List mainBooksId = [0];
        for (var i = 0; i < bookList.length; i++) {
          oldBooksId.add(bookList[i].bookid);
        }
        //contains function tells us the list already has the element or not
        for (var i = 0; i < booksId.item1!.length; i++) {
          if (oldBooksId.contains(booksId.item1![i]) == false) {
            mainBooksId.add(booksId.item1![i]);
          }
        }
        await getAllBooks(mainBooksId);
      } else {
        Get.snackbar(
            'Error',
            '${booksId.item2}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
        );
        setState(() {
          isloading = false;
        });
        //print(booksId.item2);
      }
    } else {        
      Get.snackbar(
          'Error',
          'No Internet connection',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
      );
      Future.delayed(const Duration(seconds: 3)).then((_) {
        setState(() {
          isloading = false;
        });
      });             
    }
  }

  Future<bool> getCategories(List catsId) async {
    try {      
      var response = await http.post(
      Uri.parse('${siteUrl}getcategories/$catsId'), 
        headers: {
          'Accept': 'application/json',
          'Keep-Alive': 'timeout=5, max=1',
        }
      ).timeout(const Duration(seconds: 5));

      //print(response.statusCode);
      if (response.statusCode == 200) {
        List<dynamic> categories = await jsonDecode(response.body);
        for(dynamic data in  categories){
          databaseHelperCategory.insertCategory(CategoryFromSql(data['id'], data['name']));
        }
        // categories.forEach((data) => {
          
        // });
      return true;  
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Tuple2<List?, String?>> getBooksId() async {
    try {
      var response = await http.post(
      Uri.parse('${siteUrl}booksid'), 
        headers: {
          'Accept': 'application/json',
          'Keep-Alive': 'timeout=5, max=1',
        }
      ).timeout(const Duration(seconds: 5));

      //print(response.statusCode);

      if (response.statusCode == 200) {
        List booksId = jsonDecode(response.body) as List;        
        return Tuple2(booksId, null);
      } else {
        return const Tuple2(null, 'Wrong status code, Please try again');
        
      }
    } catch (e) {
      return const Tuple2(null, 'Error, Please try again');      
    }
  }

  Future<bool> getAllBooks(List booksId) async {
    try {      
      var response = await http.post(
      Uri.parse('${siteUrl}getbooks/$booksId'), 
        headers: {
          'Accept': 'application/json',
          'Keep-Alive': 'timeout=5, max=1',
        }
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {        
        List<dynamic> books = await jsonDecode(response.body);  
        for(dynamic data in books){
          databaseHelper.insertBook(BookFromSql(data['book_id'], data['book_name'], data['book_title'], data['book_type'], data['cat_id'], data['status'], data['base64'], 0, DateTime.now().millisecondsSinceEpoch));
        }      
        
        // books.forEach((data) => {
        //   databaseHelper.insertBook(BookFromSql(data['book_id'], data['book_name'], data['book_title'], data['book_type'], data['cat_id'], data['status'], data['base64'], 0, DateTime.now().millisecondsSinceEpoch))
        // });
        await  _getData();
        return true;
      } else {        
        return false;
      }
    }  catch (e) {
      return false;
    }
  }

  Future<void> updateBook(int bookId) async {
    try{
      var response = await http.post(
      Uri.parse('${siteUrl}getbook/$bookId'), 
        headers: {
          'Accept': 'application/json',
          'Keep-Alive': 'timeout=5, max=1',
        }
      ).timeout(const Duration(seconds: 5));  

      if (response.statusCode == 200) {
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        Map<String, dynamic> data = await jsonDecode(response.body);
        BookFromSql book = BookFromSql(data['book_id'], data['book_name'], data['book_title'], data['book_type'], data['cat_id'], data['status'], data['base64'], 0, timestamp);
        await databaseHelper.updateBook(book);
        await  _getData();
      } 
    }catch (e) {
      //print("xatolik");
    }
  }

  Future<void> _runFilter(String keyWord) async{
    var result = List<BookFromSql>.empty();
    if(keyWord.isEmpty){result = bookList;}
    else{
      result = bookList.where((book) => book.bookname.toLowerCase().contains(keyWord.toLowerCase())).toList();
    }
    
    setState(() {
      _foundBook = result;
    });
  }

  Future<void>unzipEpub(int bookid) async{
    String dir = (await getApplicationDocumentsDirectory()).path;

    String bookUrl = "$dir/$bookid.zip";
    if(await File(bookUrl).exists()==true)
    {      
      // Read the Zip file from disk.
      var bytes = File("$dir/$bookid.zip").readAsBytesSync();

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

        var fileName = '$dir/$bookid$extention';
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
        GetListFromEpub getList = GetListFromEpub(name:'$bookid$extention');
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

}