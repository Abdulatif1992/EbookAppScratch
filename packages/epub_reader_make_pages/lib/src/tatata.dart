import 'package:flutter/material.dart';

class FancyConatiner extends StatefulWidget {
  const FancyConatiner({
    Key? key,
    this.height = 120.0,
    this.width,
    this.color1,
    this.color2,
    this.title = "Title",
    this.textcolor,
    this.subtitle = "Subtitle",
    this.subtitlecolor,
    this.padding,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Color? color1;
  final Color? color2;
  final String? title;
  final Color? textcolor;
  final String? subtitle;
  final Color? subtitlecolor;
  final EdgeInsetsGeometry? padding;

  @override
  State<FancyConatiner> createState() => _FancyConatinerState();
}

class _FancyConatinerState extends State<FancyConatiner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width??MediaQuery.of(context).size.width*0.90,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: const  BorderRadius.all(Radius.circular(20.0)),
        gradient: LinearGradient(
          colors: [widget.color1??const Color(0xFFCB1841), widget.color2??const Color(0xFF2604DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 12,
            offset: Offset(0,6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              '${widget.title}',
              style: TextStyle(
                color: widget.textcolor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              '${widget.title}',
              style: TextStyle(
                color: widget.textcolor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}