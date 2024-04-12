import 'package:epub_reader_make_pages/src/class/book_titles.dart';
import 'package:epub_reader_make_pages/src/views/image_view.dart';
import 'package:epub_reader_make_pages/src/views/part_of_html.dart';
import 'package:epub_reader_make_pages/src/models/books.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class ScrollBarExp3 extends StatefulWidget {
  const ScrollBarExp3({super.key, required this.bookId, required this.data, required this.page, required this.location, required this.fullHtml, required this.titles});

  final String bookId;
  final List<String> data;
  final int page;
  final double location;

  final String fullHtml;
  final List<BookTitle> titles;

  @override
  State<ScrollBarExp3> createState() => _ScrollBarExp3State();
}

class _ScrollBarExp3State extends State<ScrollBarExp3> {


  List<String>? pages;


  List<ScrollController>? _scrollControllers;
  int currentPage = 0; // Track the current page
  int currentContainerIndex = 0;
  PageController _pageController = PageController();
  bool reverseResult = false;
  bool reverseResult2 = false;
  double textSize = 16;
  String currentTitle = "";

  Color backroundColor = const Color.fromARGB(255, 220, 223, 230);
  Color backroundTextColor = Colors.black;

  //font styles=
  final List<String> items = [
    'Original',
    'AlexBrush',
    'Bentham',
    'AbhayaLibreRegular',
    'RobotoIt',
  ];
  String selectedValue = 'Original';

  @override
  void initState() {
    pages = widget.data;  
    
    currentTitle = getCurrentTitile(widget.page);

    super.initState();
    // Create a list of controllers for each SingleChildScrollView
    _scrollControllers = List.generate(pages!.length, (index) => ScrollController());
    // Add listeners if needed
    for (ScrollController controller in  _scrollControllers!) {
      controller.addListener(() {
        if(reverseResult == false){
          if (controller.position.pixels == controller.position.maxScrollExtent) {
            _nextPage();
            // Add your logic here for what you want to do when the end is reached
          }
          if(controller.position.pixels == controller.position.minScrollExtent){
            _previousPage();
          }
        }
        else{
          if (controller.position.pixels == controller.position.maxScrollExtent) {
            _previousPage();            
            // Add your logic here for what you want to do when the end is reached
          }
          if(controller.position.pixels == controller.position.minScrollExtent){
            _nextPage();
          }
        }       
        

      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _specialLocation(widget.location);
    }); 

    currentPage = widget.page;    
    _pageController = PageController(initialPage: currentPage);

  }  

  void _specialLocation(double location){
    // setState(() {
    //   reverseResult2 = true;
    // });
    _scrollControllers![currentPage].animateTo(
      location,
      duration: const Duration(milliseconds: 500), // You can adjust the duration as per your preference
      curve: Curves.easeOut, // You can adjust the curve as per your preference
    );
  }

  void _nextPage(){
    _pageController.animateToPage(_pageController.page!.toInt() + 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeIn
    );
  }

  void _previousPage(){
    _pageController.animateToPage(_pageController.page!.toInt() - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut
    );
  }

  void _specialPage(int page){
    setState(() {
      reverseResult2 = true;
    });   
    _pageController.jumpToPage(page); 
  }

  String getCurrentTitile(int page){
    String currentTitle = "";
    if(page == 0)
    {
      currentTitle = widget.titles[0].name;
      return currentTitle;
    }
    else
    {
      for( int  i =  widget.titles.length -1; i >=0; i-- ) { 
        if(widget.titles[i].page <= page){      
            currentTitle = widget.titles[i].name;    
            return currentTitle;                         
        } 
      } 
    }
    return currentTitle;
  }
  

  @override
  void dispose() {
    // Dispose of each controller
    for (ScrollController controller in  _scrollControllers!) {
      controller.dispose();
    }
    super.dispose();
  }

  bool isFooterVisible = false;
  bool settingScreen = false;


  void toggleFooterVisibility() {
    if(settingScreen==true)
    {
      settingScreenVisibility();
    }
    setState(() {
      isFooterVisible = !isFooterVisible;
    });
  }


  void settingScreenVisibility() {
    setState(() {
      settingScreen = !settingScreen;
    });
  }

  void _handleBackButtonPress(BuildContext context) async{
    HtmlBook? book;
    double scrollPosition =  _scrollControllers![currentPage].offset;
    book = HtmlBook(bookId: widget.bookId, page: currentPage, location: scrollPosition);      
    await SessionManager().set(widget.bookId, book); 
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Run your function when back button is pressed
        _handleBackButtonPress(context);
        // Return true to allow back navigation, return false to prevent it.
        return true;
      },
      child: Scaffold(      
        body: GestureDetector(
          onTap: () {
            toggleFooterVisibility();
          },
          child: Stack(
            children: [PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: pages!.length,
              onPageChanged: (index) {
                // Determine if it's a next or previous page
                if (index > currentPage) {
                  setState(() {
                    reverseResult = false;
                  });
                  // Do something for the next page
                } else if (index < currentPage) {
                  if(reverseResult2 == true){
                    setState(() {                        
                      reverseResult = false;
                      reverseResult2 = false;
                    });

                  } else {
                    setState(() {
                      reverseResult = true;
                    });
                    // Do something for the previous page
                  }
                    
                }    
                // Update the current page
                setState(() {
                  currentPage = index;
                });

                setState(() {
                  currentTitle = getCurrentTitile(index);
                });  
                
              },
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  //margin: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                  color: backroundColor,
                  child: Scrollbar
                  (
                    trackVisibility: true,
                    thickness: 10.0,
                    radius: const Radius.circular(12),
                    thumbVisibility:true,
                    interactive: true,
                    controller: _scrollControllers![index],
                    child: SingleChildScrollView(
                      reverse: reverseResult,
                      controller: _scrollControllers![index],
                      child: Html(
                        data: "<div style='font-size: ${textSize}px; font-family: $selectedValue; color: #${backroundTextColor.value.toRadixString(16)};'> ${pages![index]} </div>",
                        extensions: [
                          OnImageTapExtension(
                              onImageTap: (src, imgAttributes, element) {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => FullScreenImageViewer(src!)));
                              },
                          ), 
                          const TableHtmlExtension(),  
                          TagWrapExtension(
                            tagsToWrap: {"pagebr"},
                            builder: (child){
                              return child;
                            },
                          ),             
                        ],  
                        onLinkTap: (url, _, __) {
                          debugPrint("Opening $url...");
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PartOfHtml(url: url!, fullHtml: widget.fullHtml)));
                        },
                        style: {
                          // tables will have the below background color
                          "table": Style(
                            backgroundColor: const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                          ),
                          // some other granular customizations are also possible
                          "tr": Style(
                            border: const Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          "th": Style(
                            //padding:  MaterialStateProperty.all(EdgeInsets.all(6)),
                            backgroundColor: Colors.grey,
                          ),
                          "td": Style(
                            //padding: EdgeInsets.all(6),
                            alignment: Alignment.topLeft,
                          ),
                          // text that renders h1 elements will be red
                          //"h1": Style(color: Colors.red),
                        },                        
                      ),
                    ),
                  ),
                );
              },
            ),
            Visibility(
              visible: isFooterVisible,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _appBar(),
                  _footer(),
                ],
              ),
            ),
            Visibility(
              visible: settingScreen,
              child: _settingsScreen(),
            ),
            ]
          ),
        ),
      ),
    );
  }  

  Widget _menuButton(){
    return PopupMenuButton<String>(
      color: const Color.fromARGB(255, 238, 231, 232),
      offset: const Offset(0, 54),
      icon: const Icon(Icons.menu),
      onSelected: (String result) {
        // Handle the selection from the dropdown menu here
        //print("Tushunmadim nega qayta ishlaydi "); // For demonstration, printing the selected item
        setState(() {
          currentTitle = widget.titles[int.parse(result)].name;
        });    
        _specialPage(widget.titles[int.parse(result)].page);
      },
      itemBuilder: (BuildContext context) {
        return widget.titles.map((BookTitle title) {
          return PopupMenuItem<String>(
            value: "${title.index}",
            child: Text(title.name),
          );
        }).toList();
      }
    );
  }

  Widget _appBarTitle(){
    return Container(
      width: MediaQuery.of(context).size.width-130.0,
      height: 50,
      //color: Colors.blue,   
      alignment: Alignment.centerLeft,                         
      child: Text(
        currentTitle, 
        textAlign: TextAlign.center, 
        overflow: TextOverflow.ellipsis, 
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _settingsIcon(){
    return IconButton(
      icon: const Icon(Icons.settings),
      color: Colors.white,
      iconSize: 30,
      tooltip: 'Increase volume by 10',
      onPressed: () {
        settingScreenVisibility();
      },
    );
  }

  Widget _appBar(){
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(10, 30, 10, 10),
      color: const Color.fromARGB(255, 231, 51, 90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuButton(),
          _appBarTitle(),            
          _settingsIcon(),
        ],
      ),
    );
  }

  Widget _footer(){
    return Container(
      height: 30,
      margin: const EdgeInsets.fromLTRB(10, 30, 10, 10),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      color: const Color.fromARGB(255, 231, 51, 90).withOpacity(0.7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.navigate_before),
            tooltip: 'Increase volume by 10',
            onPressed: () {_previousPage();},
          ),
          Text(" ${currentPage+1} / ${pages!.length}",style: const TextStyle(color: Colors.white),),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Increase volume by 10',
            onPressed: () {_nextPage();},
          ),
        ],
      ),
    );
  }

  Widget _settingsScreen(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 85, 10, 10),
          height: 250,
          width: 250,
          color: const Color.fromARGB(255, 238, 231, 232),
          child: Column(
            children: [
              _settingsSettingContainer(),
              _settingsTextSize(),
              _settingsTextFont(),
              const SizedBox(height: 20,),
              _settingsViewMode(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsSettingContainer(){
    return Container(
      height: 40,
      width: 250,
      alignment: Alignment.center,
      color: const Color.fromARGB(255, 231, 51, 90),
      child: const Text("settings", style:TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  Widget _settingsTextSize(){
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 18,
            icon: const Icon(Icons.format_color_text),
            tooltip: 'Increase volume by 10',
            onPressed: () {
              setState(() {
                textSize -= 2;
              });
            },
          ),
          const SizedBox(width: 50,),
          IconButton(
            icon: const Icon(Icons.format_color_text),
            iconSize: 30,
            tooltip: 'Increase volume by 10',
            onPressed: () {
              setState(() {
                textSize += 2;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _settingsTextFont(){
    return DropdownButton(
      value: selectedValue,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          selectedValue = value!;
        });
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _settingsViewMode(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(onPressed: (){
            setState(() {
              backroundColor = const Color.fromARGB(255, 235, 233, 233);
              backroundTextColor = Colors.black;
            });
          },                              
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),),padding: const EdgeInsets.all(6),),
          child: const Text('default', style: TextStyle(color: Colors.black),),
        ),

        OutlinedButton(onPressed: (){
            setState(() {
              backroundColor = const Color.fromARGB(124, 196, 196, 166);
              backroundTextColor = Colors.black;
            });
          },                               
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),),padding: const EdgeInsets.all(6),), 
          child: const Text('sepia', style: TextStyle(color: Colors.black),), 
        ),

        OutlinedButton(onPressed: (){
            setState(() {
              backroundColor = const Color.fromARGB(255, 22, 22, 22);
              backroundTextColor = Colors.white;
            });
          },                              
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),),padding: const EdgeInsets.all(6),), 
          child: const Text('night', style: TextStyle(color: Colors.black),),
        ),                              
      ],
    ); 
  }   

}