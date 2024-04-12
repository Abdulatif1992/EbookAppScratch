import 'package:flutter/material.dart';
import 'dart:convert';

class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer(this.src,{Key? key}) : super(key: key);
  final String src;
  @override
  Widget build(BuildContext context) {
    const find = 'data:image/jpeg;base64,';
    const find2 = 'data:image/png;base64,';
    const replaceWith = '';
    String base64Image = src.replaceAll(find, replaceWith);
    base64Image = base64Image.replaceAll(find2, replaceWith);

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color.fromARGB(255, 162, 161, 163),
        backgroundColor: const Color.fromARGB(255, 239, 238, 240),
          automaticallyImplyLeading: false,
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
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          maxScale: 4.0,
          minScale: 1.0,
          //boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Image.memory(base64Decode(base64Image)),        
        ),
        
        
      ),
    );

    // return Scaffold(
    //   body: GestureDetector(
    //     child: SizedBox(
    //       width: MediaQuery.of(context).size.width,
    //       height: MediaQuery.of(context).size.height,
    //       child: Hero(
    //         tag: 'imageHero',
    //         //child: Text(base64Image),
    //         child: Image.memory(base64Decode(base64Image)),
    //         //child: Image.network("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png"),
    //       ),
    //     ),
    //     onTap: () {
    //       Navigator.pop(context);
    //     },
    //   ),
    // );
  }
}