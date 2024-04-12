//import 'package:ebook_app_scratch/authentication/login_page.dart';
import 'package:ebook_app_scratch/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: HomeScreen()
      //home: LoginPage()
    );
  }
}