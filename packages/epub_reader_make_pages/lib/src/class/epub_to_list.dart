import 'package:epub_reader_make_pages/src/class/book_titles.dart';
import 'package:epubx/epubx.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
//it is for tuple function
import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'dart:typed_data';

class GetListFromEpub {
  GetListFromEpub({required this.name,});

  final String name;
  
  Future <Tuple2<List<String>, List<BookTitle>>>   parseEpubWithChapters() async {
    var dir = await getApplicationDocumentsDirectory();
    String filename = name;
    
    io.File file = io.File('${dir.path}/$filename');
    List<int> bytes = await file.readAsBytes();


    // Opens a book and reads all of its content into memory
    EpubBook epubBook = await EpubReader.readBook(bytes);
    bool imgSaver = await saveImages(epubBook);
    if(imgSaver == true)
    {
      // Enumerating chapters
      String htmlContent = "";
      List<String> list = []; 
      int pageNumber = 0;
      List<BookTitle> titles = [];

      //for (EpubChapter chapter in epubBook.Chapters!) {
      for (int index = 0; index < epubBook.Chapters!.length; index++) {  
        EpubChapter chapter = epubBook.Chapters![index];
        // Title of chapter
        //String chapterTitle = chapter.Title!;

        titles.add(BookTitle(name: chapter.Title!, page: pageNumber, index: index));
                    
        // HTML content of current chapter
        String chapterHtmlContent = chapter.HtmlContent!;

        //Extract image URLs from HTML content
        RegExp exp = RegExp(r'<img[^>]+src="([^">]+)"');
        Iterable<Match> matches = exp.allMatches(chapterHtmlContent);

        // Iterate through image URLs
        for (Match match in matches) {
          String imageUrl = match.group(1)!;
          String imageUrlWithoutPrefix = imageUrl.replaceAll('images/', '');
          
          // Load image file and convert to base64
          List<int> imageBytes = await io.File('${dir.path}/$imageUrlWithoutPrefix').readAsBytes();
          String base64Image = base64Encode(imageBytes);

          // Replace image URL with base64 encoded data in HTML content
          chapterHtmlContent = chapterHtmlContent.replaceFirst(imageUrl, 'data:image/png;base64,$base64Image');
        }


        htmlContent += chapterHtmlContent;

        String delimiter = "<pagebr></pagebr>";
        int delimiterIndex = chapterHtmlContent.indexOf(delimiter);

        if (delimiterIndex != -1) {
          int startIndex = 0;

          while (delimiterIndex != -1) {
            list.add(chapterHtmlContent.substring(startIndex, delimiterIndex).trim());
            startIndex = delimiterIndex + delimiter.length;          
            delimiterIndex = chapterHtmlContent.indexOf(delimiter, startIndex);
            pageNumber += 1;
          }

          // Add the remaining content if any
          if (startIndex < chapterHtmlContent.length) {
            list.add(chapterHtmlContent.substring(startIndex).trim());
            pageNumber += 1;
          }
        }
        else{        
          list.add(chapterHtmlContent.trim());
          pageNumber += 1;
        }

        // Nested chapters
        // List<EpubChapter> subChapters = chapter.SubChapters!;
      }    

      list.add(htmlContent);
      return Tuple2(list, titles);
    }
    return const Tuple2([], []);

  }  
  
  Future<bool> saveImages(EpubBook epubBook) async {
    var dir = await getApplicationDocumentsDirectory();
    EpubContent? bookContent = epubBook.Content;

    try{
      if (bookContent != null) {
        Map<String, EpubByteContentFile>? images = bookContent.Images;

        if (images != null && images.isNotEmpty) {
          for (var imageName in images.keys) {
            // Get image data
            String imageNameWithoutPrefix = imageName.replaceAll('images/', '');
            EpubByteContentFile? imageData = images[imageName];
            if (imageData != null) {
              // Convert image data to Uint8List
              Uint8List bytes = Uint8List.fromList(imageData.Content!);

              // Create a file in the current directory
              String filePath = '${dir.path}/$imageNameWithoutPrefix';
              io.File imageFile = io.File(filePath);

              // Write image data to the file
              await imageFile.writeAsBytes(bytes);
            }
          }
        }
      }

      return true;
    }on Exception catch (_) {
      return false;
    }
    
    
  }
  
}  