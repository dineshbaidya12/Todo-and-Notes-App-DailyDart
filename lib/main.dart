// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:todoapp1/pages/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Dart',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color.fromARGB(255, 92, 195, 255)),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'popins',
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List<int> strengths = <int>[
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int strength in strengths) {
      final double ds = 0.5 - ((strength / 1000.0) / 2.0);
      swatch[strength] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}
