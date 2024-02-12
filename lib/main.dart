import 'package:flutter/material.dart';
import 'package:flutter_google_maps/pages/home_page.dart';
import 'package:flutter_google_maps/pages/maps_v1_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
