import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

class PartOfHtml extends StatelessWidget {
  const PartOfHtml({
    super.key,

    required this.url, 
    required this.fullHtml, 
  });

  final String url;
  final String fullHtml;  
  

  @override
  Widget build(BuildContext context) {

    dom.Document document = htmlparser.parse(fullHtml);

    String priceElement = "";

    bool id = url.contains('id:');
    bool class1 = url.contains('class:'); 
    if(id==true){
      priceElement = document.getElementById("something")!.innerHtml;
      //print("id");
    }
    else if(class1 == true){
      //print("class");
      //priceElement = document.getElementsByClassName("xurshid_bilan_laylo");
    }
    else{
      //print("nomalum");
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 239, 238, 240),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size:50, color: Colors.black,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Html(
          data: priceElement,
        ),
      ),
    );
  }
}