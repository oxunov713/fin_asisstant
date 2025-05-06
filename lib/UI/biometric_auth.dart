import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/text_to_speech_service.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextToSpeechService _tts = TextToSpeechService();
  final TextEditingController _passwordController = TextEditingController();

  bool _isBiometricEnabled = false;
  bool _canUseBiometric = false;
  String _storedPassword = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkBiometricSupport();
    await _loadSettings();
    await _welcomeMessage();
  }

  Future<void> _welcomeMessage() async {
    if (_tts.isEnabled) {
      await _tts.speak("Xavfsizlik sozlamalari ekrani. Bu yerda biometrik kirish va ovozli yo'riqnoma sozlamalarini o'zgartirishingiz mumkin");
    }
  }

  Future<void> _checkBiometricSupport() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    setState(() {
      _canUseBiometric = canCheck && isDeviceSupported;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = await _secureStorage.read(key: 'app_password') ?? '';
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _storedPassword = stored;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', _isBiometricEnabled);
    if (_passwordController.text.isNotEmpty) {
      await _secureStorage.write(key: 'app_password', value: _passwordController.text);
      setState(() {
        _storedPassword = _passwordController.text;
      });
    }
  }

  Future<bool> _authenticate() async {
    try {
      if (_tts.isEnabled) {
        await _tts.speak("Biometrik autentifikatsiya boshlandi");
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Ilovaga kirish uchun barmoq izi kerak',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (_tts.isEnabled) {
        await _tts.speak(
            didAuthenticate ? "Muvaffaqiyatli tasdiqlandi" : "Tasdiqlash bekor qilindi");
      }

      return didAuthenticate;
    } catch (e) {
      if (_tts.isEnabled) {
        await _tts.speak("Xatolik: ${e.toString()}");
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xavfsizlik Sozlamalari')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Ovozli yo\'riqnoma (TTS)'),
                value: _tts.isEnabled,
                onChanged: (value) async {
                  await _tts.toggleTTS(value);
                  setState(() {});
                  if (value && _tts.isEnabled) {
                    await _tts.speak("Ovozli yo'riqnoma yoqildi");
                  }
                },
              ),
              const Divider(height: 30),
              SwitchListTile(
                title: const Text('Biometrik kirish'),
                value: _isBiometricEnabled,
                onChanged: _canUseBiometric
                    ? (value) async {
                  setState(() => _isBiometricEnabled = value);
                  await _saveSettings();
                  if (_tts.isEnabled) {
                    await _tts.speak(
                        value ? "Biometrik kirish yoqildi" : "Biometrik kirish o'chirildi");
                  }
                }
                    : null,
                subtitle: !_canUseBiometric
                    ? const Text('Qurilmangiz biometrikani qo\'llab-quvvatlamaydi')
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Yangi kalit so\'z',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Kamida 6 ta belgi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_passwordController.text.length < 6) {
                    if (_tts.isEnabled) {
                      await _tts.speak("Kalit so'z kamida 6 ta belgidan iborat bo'lishi kerak");
                    }
                    return;
                  }

                  final confirmed = true;
                  if (confirmed) {
                    await _saveSettings();
                    if (_tts.isEnabled) {
                      await _tts.speak("Kalit so'z o'rnatildi");
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kalit so'z muvaffaqiyatli saqlandi")),
                    );
                  }
                },
                child: const Text("Kalit so'z o'rnatish"),
              ),
              const SizedBox(height: 30),
              if (_isBiometricEnabled)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    label: const Text("Biometrik tekshirish"),
                    onPressed: () async {
                      final auth = await _authenticate();
                      if (auth && _tts.isEnabled) {
                        await _tts.speak("Biometrik autentifikatsiya muvaffaqiyatli");
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _tts.stop();
    super.dispose();
  }
}
