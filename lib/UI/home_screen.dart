import 'package:flutter/material.dart';
import 'package:my_fin_asisstant/service/speech_to_text_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/text_to_speech_service.dart';
import 'categories_page.dart';
import 'home_page.dart';
import '../main.dart';
import 'profile_page.dart';
import 'service_screen.dart';
import 'transfers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextToSpeechService _tts = TextToSpeechService();

  final List<Widget> _pages = [
    HomePage(),
    ServicesSection(),
    VoiceTransferUI(
      stt: SpeechToTextService(),
      tts: TextToSpeechService(),

    ),
    CategoriesPage(),
    ProfileScreen(),
  ];

  final List<String> _labels = [
    'Bosh sahifa',
    'Xizmatlar',
    "O'tkazmalar",
    'Tahlil',
    'Profil',
  ];

  void _onTabTapped(int index) {
    _tts.speak(_labels[index]);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        // To‘g‘ri callback
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: _labels[0]),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: _labels[1],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horizontal_circle_rounded),
            label: _labels[2],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: _labels[3],
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: _labels[4]),
        ],
      ),
    );
  }
}
