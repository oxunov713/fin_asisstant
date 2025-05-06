import 'dart:async';

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../service/api_service.dart';
import '../service/text_to_speech_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BankModel> banks = [];
  final TextToSpeechService _tts = TextToSpeechService();
  bool _isSpeaking = false;

  // In your widget state class, add these variables
  int _currentBannerIndex = 0;
  final List<Map<String, dynamic>> _banners = [
    {
      'text': 'Special Offer: 20% discount this week!',
      'color': Color(0xffFF6B6B),
      'image': 'assets/discount.png', // Replace with your actual asset
    },
    {
      'text': 'New features available - try now!',
      'color': Color(0xff4ECDC4),
      'image': 'assets/new_features.png',
    },
    {
      'text': 'Limited time deal - don\'t miss out!',
      'color': Color(0xff45B7D1),
      'image': 'assets/deal.png',
    },
  ];

  // Add this timer initialization in initState()
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _tts.setEngine("RHVoice");
    _fetchBankData();
    _startBannerRotation();
  }

  Future<void> _fetchBankData() async {
    final fetchedBanks = await ApiService().fetchBanks();
    setState(() {
      banks = fetchedBanks;
    });
  }

  void _startBannerRotation() {
    _bannerTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
      });
    });
  }

  String _translateCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return 'AQSH dollari';
      case 'EUR':
        return 'Yevro';
      case 'RUB':
        return 'Rubl';
      case 'GBP':
        return 'Funt sterling';
      default:
        return currency;
    }
  }

  Future<void> _speakWithFeedback(String text) async {
    setState(() {
      _isSpeaking = true;
    });
    await _tts.speak(text);
    setState(() {
      _isSpeaking = false;
    });
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return '';
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _speakWithFeedback('Salom, xush kelibsiz. Xayrli tong'),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Welcome back',
                style: TextStyle(
                  color: Color(0xff052224),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Good Morning',
                style: TextStyle(color: Color(0xff052224), fontSize: 14),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _speakWithFeedback('Bildirishnomalar'),
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xffDFF7E2),
                child: Icon(Icons.notifications),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Balance Card
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: GestureDetector(
              key: ValueKey<int>(_currentBannerIndex),
              onTap:
                  () =>
                      _speakWithFeedback(_banners[_currentBannerIndex]['text']),
              child: Container(
                key: ValueKey<int>(_currentBannerIndex),
                height: 150,
                width: double.infinity,
                color: _banners[_currentBannerIndex]['color'],
                child: Center(
                  child: Text(
                    _banners[_currentBannerIndex]['text'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),

          // Your Banks Section
          GestureDetector(
            onTap: () => _speakWithFeedback('Sizning banklaringiz'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Text(
                "Your Banks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                final bankName = bank.name!;
                final bankColor = Colors.deepPurple;

                return GestureDetector(
                  onTap: () => _speakWithFeedback('Bank nomi: $bankName'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bankColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bankColor, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          bank.image ?? "",
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.account_balance),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bankName,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Currency Exchange Section
          GestureDetector(
            onTap: () => _speakWithFeedback('Valyuta kurslari'),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Currency Exchange",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListView.builder(
            itemCount: banks.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final bank = banks[index];

              return GestureDetector(
                onTap:
                    () => _speakWithFeedback(
                      '${bank.name} banki valyuta kurslari. ${bank.exchangeRates!.map((rate) {
                        final currencyName = _translateCurrency(rate.currency!);
                        return '1 $currencyName ${rate.toBuy} so\'mga sotib olinadi, ${rate.toSell} so\'mga sotiladi';
                      }).join('. ')}',
                    ),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Bank name
                        GestureDetector(
                          onTap: () => _speakWithFeedback('${bank.name} banki'),
                          child: Text(
                            textAlign: TextAlign.start,
                            bank.name!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Exchange rates
                        Wrap(
                          spacing: 100,
                          runSpacing: 50,
                          children:
                              bank.exchangeRates!.map((rate) {
                                final currencyName = _translateCurrency(
                                  rate.currency!,
                                );
                                return GestureDetector(
                                  onTap:
                                      () => _speakWithFeedback(
                                        '1 $currencyName ${rate.toBuy} so\'mga sotib olinadi, ${rate.toSell} so\'mga sotiladi',
                                      ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rate.currency!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.arrow_downward,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          Text("${rate.toBuy}"),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.arrow_upward,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          Text("${rate.toSell}"),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isSpeaking) {
            _tts.stop();
            setState(() {
              _isSpeaking = false;
            });
          } else {
            _speakWithFeedback(
              'Bosh sahifa. Umumiy balansingiz 517 ming so\'m. '
              'Umumiy xarajatingiz 517 ming so\'m. '
              'Sizda ${banks.length} ta bank mavjud. '
              'Valyuta kurslari: ${banks.map((bank) {
                return '${bank.name} bankida ${bank.exchangeRates!.map((rate) {
                  final currencyName = _translateCurrency(rate.currency!);
                  return '1 $currencyName ${rate.toBuy} so\'m';
                }).join(', ')}';
              }).join('. ')}',
            );
          }
        },
        backgroundColor: _isSpeaking ? Colors.red : Colors.blue,
        child: Icon(
          _isSpeaking ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
        ),
      ),
    );
  }
}
