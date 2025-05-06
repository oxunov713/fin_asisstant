import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'UI/home_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Color(0xff00D09E)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xff00D09E),
        ),
        fontFamily: "Cascad",
      ),
      home: HomeScreen(),
    );
  }
}
