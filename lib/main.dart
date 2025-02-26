import 'package:flutter/material.dart';
import 'package:praktikum3/screens/camera_page.dart';
import 'package:praktikum3/screens/home_page.dart';
import 'package:praktikum3/screens/image_list_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akses Perangakat Keras',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/camera': (context) => CameraPage(),
        '/listview': (context) => ImageListPage(),
      },
    );
  }
}

