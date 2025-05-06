import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isEnabled = true; // Default state is enabled

  // Singleton pattern
  static final TextToSpeechService _instance = TextToSpeechService._internal();

  factory TextToSpeechService() => _instance;

  TextToSpeechService._internal() {
    _init();
  }

  Future<void> _init() async {
    await _loadSettings();
    await _initialize();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('tts_enabled') ?? true;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_enabled', _isEnabled);
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final engines = await _flutterTts.getEngines;
      print("Available engines: $engines");

      await _flutterTts.setEngine("RHVoice");

      // Set language to Uzbek
      final languages = await _flutterTts.getLanguages;
      print("Available languages: $languages");
      if (languages.contains("uz-UZ")) {
        await _flutterTts.setLanguage("uz-UZ");
      }

      // Set voice to Dilnavoz
      final voices = await _flutterTts.getVoices;
      print("Available voices: $voices");

      await _flutterTts.setPitch(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.55);
      await _flutterTts.speak("Assalomu alaykum");
      _isInitialized = true;
    } catch (e) {
      print("TTS initialization error: $e");
      _isInitialized = false;
    }
  }

  // Toggle TTS state (enable/disable)
  Future<void> toggleTTS(bool enabled) async {
    _isEnabled = enabled;
    await _saveSettings();
    if (!enabled) {
      await stop();
    }
  }

  // Get TTS state
  bool get isEnabled => _isEnabled;

  // Speak the given text
  Future<void> speak(String text) async {
    if (!_isEnabled) return;

    try {
      await _initialize();

      if (!_isInitialized) {
        print("TTS not initialized, cannot speak");
        return;
      }
      await _flutterTts.stop();

      await _flutterTts.speak(text);
    } catch (e) {
      print("Speak error: $e");
    }
  }

  // Stop TTS
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Stop error: $e");
    }
  }

  Future<void> setEngine(String engine) async {
    try {
      await _flutterTts.setEngine(engine);
    } catch (e) {
      print("Stop error: $e");
    }
  }
}
