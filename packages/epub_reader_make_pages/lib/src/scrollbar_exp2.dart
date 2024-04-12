import 'package:flutter/material.dart';
import 'package:epub_reader_make_pages/src/views/image_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:epub_reader_make_pages/src/class/book_titles.dart';

class ScrollBarExp2 extends StatelessWidget {
  const ScrollBarExp2({
    Key? key,
    required this.data,
    required this.page,
    required this.location,
    required this.fullHtml,
    required this.titles,
  }) : super(key: key);

  final List<String> data;
  final int page;
  final double location;
  final String fullHtml;
  final List<BookTitle> titles;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrollbar with SingleChildScrollView',
      home: Scaffold(
        body: CustomScrollViewWithSmallScrollbar(
          key: UniqueKey(),
          lastLocation: location,
          titles: titles,
          fullHtml: fullHtml,
          textSize: 16,
        ),
      ),
    );
  }
}

class CustomScrollViewWithSmallScrollbar extends StatefulWidget {
  final double lastLocation;
  final List<BookTitle> titles;
  final String fullHtml;
  final double textSize;

  const CustomScrollViewWithSmallScrollbar({
    Key? key,
    required this.lastLocation,
    required this.titles,
    required this.fullHtml,
    required this.textSize,
  }) : super(key: key);

  @override
  State<CustomScrollViewWithSmallScrollbar> createState() =>
      _CustomScrollViewWithSmallScrollbarState();
}

class _CustomScrollViewWithSmallScrollbarState
    extends State<CustomScrollViewWithSmallScrollbar> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _textSizeNotifier = ValueNotifier<double>(16);

  String? html;

  @override
  void initState() {
    html = widget.fullHtml;
    super.initState();
    //_scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _textSizeNotifier.dispose();
    super.dispose();
  }

  void _scrollListener() {
    double current =
        _scrollController.offset * 100 / _scrollController.position.maxScrollExtent;
    setState(() {
      currentPersent = current.toStringAsFixed(0);
    });
    
  }



  double textSize = 16;
  Color backroundColor = const Color.fromARGB(255, 220, 223, 230);
  Color backroundTextColor = Colors.black;

  final List<String> items = [
    'Original',
    'AlexBrush',
    'Bentham',
    'AbhayaLibreRegular',
    'RobotoIt',
  ];
  String selectedValue = 'Original';

  String currentTitle = "";
  String currentPersent = "0";

  bool isFooterVisible = false;
  bool settingScreen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        toggleFooterVisibility();
      },
      child: Stack(children: [
        Scrollbar(
          controller: _scrollController,
          thickness: 10,
          thumbVisibility: true,
          radius: const Radius.circular(6),
          interactive: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              color: backroundColor,
              child: Html(
                data: "<div style='font-size: ${textSize}px; font-family: $selectedValue; color: #${backroundTextColor.value.toRadixString(16)};'> $html </div>",
                extensions: [
                  OnImageTapExtension(
                    onImageTap: (src, imgAttributes, element) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(src!)));
                    },
                  ),
                  const TableHtmlExtension(),
                  TagWrapExtension(
                    tagsToWrap: {"pagebr"},
                    builder: (child) {
                      return child;
                    },
                  ),
                ],
                onLinkTap: (url, _, __) {},
                style: {
                  "table": Style(
                    backgroundColor: const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                  ),
                  "tr": Style(
                    border: const Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  "th": Style(
                    backgroundColor: Colors.grey,
                  ),
                  "td": Style(
                    alignment: Alignment.topLeft,
                  ),
                },
              ),
            ),
          ),
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
      ]),
    );
  }

  void toggleFooterVisibility() {
    if (settingScreen == true) {
      settingScreenVisibility();
    }
    setState(() {
      isFooterVisible = !isFooterVisible;
    });
    _scrollListener();
  }

  void settingScreenVisibility() {
    setState(() {
      settingScreen = !settingScreen;
    });
  }

  // Function to increase text size
  void increaseTextSize() {
    setState(() {
      textSize += 2;
    });
    
  }

  // Function to decrease text size
  void decreaseTextSize() {
    setState(() {
      textSize -= 2;
    });
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
        //_specialPage(widget.titles[int.parse(result)].page);
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
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
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
      margin: const EdgeInsets.fromLTRB(10, 30, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      color: const Color.fromARGB(255, 231, 51, 90).withOpacity(0.7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [          
          Text("$currentPersent% / 100%",style: const TextStyle(color: Colors.white),),         
        ],
      ),
    );
  }

  Widget _settingsScreen(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 75, 10, 10),
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
              decreaseTextSize();
            },
          ),
          const SizedBox(width: 50,),
          IconButton(
            icon: const Icon(Icons.format_color_text),
            iconSize: 30,
            tooltip: 'Increase volume by 10',
            onPressed: () {
              increaseTextSize();
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