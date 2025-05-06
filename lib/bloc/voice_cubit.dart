import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:my_fin_asisstant/bloc/voice_state.dart';
import 'package:my_fin_asisstant/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/speech_to_text_service.dart';
import '../service/text_to_speech_service.dart';

class VoiceTransferCubit extends Cubit<VoiceTransferState> {
  final TextToSpeechService _tts;
  final SpeechToTextService _stt;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  final SharedPreferences _prefs;
  String? _storedConfirmationWord;

  VoiceTransferCubit(this._tts, this._stt, this._prefs)
    : _storedConfirmationWord = _prefs.getString('confirmation_word'),
      super(VoiceTransferInitial());

  Future<void> updateConfirmationWord(String newWord) async {
    await _prefs.setString('confirmation_word', newWord);
    _storedConfirmationWord = newWord;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    emit(VoiceTransferInitial(isProcessing: true));

    try {
      await _stt.initialize();
      _isInitialized = true;
      _storedConfirmationWord = _prefs.getString('confirmation_word');
      if (_storedConfirmationWord == null) {
        _storedConfirmationWord = 'piyola';
        await _prefs.setString('confirmation_word', _storedConfirmationWord!);
      }
      await _speakWithSync('Kimga o\'tkazmoqchisiz? Ismini aytib bering');
      emit(
        VoiceTransferRecipientState(
          statusMessage: 'Kimga o\'tkazmoqchisiz? Ismini aytib bering',
        ),
      );
    } catch (e) {
      emit(
        VoiceTransferErrorState(
          errorMessage: 'Initialization failed: $e',
          statusMessage: 'Tizimni ishga tushirishda xatolik',
          isProcessing: false,
        ),
      );
    }
  }

  Future<void> startListening() async {
    if (state.isProcessing ||
        !_isInitialized ||
        _isSpeaking ||
        state.isListening)
      return;

    try {
      emit(
        state.copyWith(
          recognizedText: '',
          isProcessing: true,
          isListening: true,
          errorMessage: null,
        ),
      );

      await _stt.startListening(
        onResult: _handleSpeechResult,
        onListeningStarted: () {},
        onListeningStopped: () {
          emit(state.copyWith(isListening: false, isProcessing: false));
        },
      );
    } catch (e) {
      _handleSpeechError('Mikrofondan foydalanishda xatolik: $e');
    }
  }

  Future<void> stopListening() async {
    if (!state.isListening) return;

    try {
      await _stt.stopListening();
      emit(state.copyWith(isListening: false, isProcessing: false));
    } catch (e) {
      emit(
        state.copyWith(
          isListening: false,
          isProcessing: false,
          errorMessage: 'Mikrofondan to\'xtatishda xatolik',
        ),
      );
      await _speakWithSync('Mikrofondan foydalanishda xatolik yuz berdi');
    }
  }

  Future<void> _handleSpeechResult(String text) async {
    if (!_isInitialized || _isSpeaking) return;

    emit(state.copyWith(recognizedText: text));

    if (state is VoiceTransferRecipientState) {
      await _processRecipient(text);
    } else if (state is VoiceTransferAmountState) {
      await _processAmount(text);
    } else if (state is VoiceTransferConfirmationState) {
      await _processConfirmation(text);
    }
  }

  Future<void> _handleSpeechError(String error) async {
    await stopListening();
    emit(
      VoiceTransferErrorState(
        errorMessage: error,
        statusMessage: 'Xatolik yuz berdi. Iltimos, qaytadan urinib ko\'ring',
        isProcessing: false,
      ),
    );
    await _speakWithSync(
      'Xatolik yuz berdi. Iltimos, qaytadan urinib ko\'ring',
    );
    // Xatolikdan keyin avtomatik ravishda tinglashni boshlash beqarorlikka olib kelishi mumkin.
    // Foydalanuvchi o'zi qayta urinishi uchun imkoniyat qoldirish yaxshiroq.
  }

  Future<void> _processRecipient(String name) async {
    if (name.isEmpty) {
      await _speakWithSync('Iltimos, ismni aniqroq aytib bering');
      await startListening();
      return;
    }

    emit(state.copyWith(isProcessing: true));

    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      Contact? foundContact;

      for (var contact in contacts) {
        if (contact.displayName.toLowerCase().contains(name.toLowerCase())) {
          foundContact = contact;
          break;
        }
      }

      if (foundContact != null) {
        await _speakWithSync(
          'Kontakt topildi. ${foundContact.displayName} ga qancha pul o\'tkazmoqchisiz?',
        );
        emit(
          VoiceTransferAmountState(
            selectedContact: foundContact,
            statusMessage:
                '${foundContact.displayName} ga qancha pul o\'tkazmoqchisiz?',
          ),
        );
      } else {
        emit(
          VoiceTransferRecipientState(
            statusMessage:
                '$name nomli kontakt topilmadi. Kimga o\'tkazmoqchisiz?',
            errorMessage: 'Kontakt topilmadi',
          ),
        );
        await _speakWithSync(
          '$name nomli kontakt topilmadi. Boshqa kontakt nomini aytib bering',
        );
        // Diqqat: Bu yerda darhol startListening() chaqirilmayapti.
        // Foydalanuvchi javob berishi uchun kutish kerak.
        // Agar kerak bo'lsa, ma'lum vaqtdan keyin yoki foydalanuvchi harakati bilan tinglashni boshlash mumkin.
      }
    } catch (e) {
      emit(
        VoiceTransferErrorState(
          errorMessage: 'Kontaktlarni o\'qishda xatolik',
          statusMessage:
              'Kontaktlarni o\'qishda xatolik yuz berdi. Kimga o\'tkazmoqchisiz?',
          isProcessing: false,
        ),
      );
      await _speakWithSync(
        'Kontaktlarni o\'qishda xatolik yuz berdi. Iltimos, qaytadan urinib ko\'ring',
      );
      // Bu yerda ham darhol startListening() chaqirilmayapti.
    } finally {
      emit(state.copyWith(isProcessing: false));
    }
  }

  Future<void> _processConfirmation(String text) async {
    if (_storedConfirmationWord != null &&
        text.toLowerCase().contains(_storedConfirmationWord!.toLowerCase())) {
      final currentState = state as VoiceTransferConfirmationState;
      await _speakWithSync(
        'O\'tkazma tasdiqlandi. ${currentState.selectedContact.displayName} ga ${currentState.amount} so\'m o\'tkazilmoqda',
      );
      await _performTransfer(currentState.selectedContact, currentState.amount);
    } else {
      await _speakWithSync(
        'Tasdiqlash so\'zi noto\'g\'ri. Jarayon bekor qilindi. Yangi o\'tkazma uchun kimga o\'tkazmoqchisiz?',
      );
      emit(
        VoiceTransferRecipientState(
          statusMessage: 'Yangi o\'tkazma uchun kimga o\'tkazmoqchisiz?',
        ),
      );
    }
  }

  Future<void> _processAmount(String text) async {
    final amount = _extractAmount(text);

    if (amount.isNotEmpty) {
      final currentState = state as VoiceTransferAmountState;
      final formattedAmount = _formatAmountWithSpaces(
        amount,
      ); // Qo'shimcha formatlash
      await _speakWithSync(
        '$formattedAmount so\'mni ${currentState.selectedContact.displayName} ga o\'tkazishni tasdiqlash uchun kalit so\'zni aytib bering',
      );
      emit(
        VoiceTransferConfirmationState(
          selectedContact: currentState.selectedContact,
          amount: amount,
          // Saqlash uchun toza sonni ishlatamiz
          recognizedText: formattedAmount,
          // Ovozli takrorlash uchun formatlangan summani saqlaymiz
          statusMessage:
              '$formattedAmount so\'mni ${currentState.selectedContact.displayName} ga o\'tkazishni tasdiqlash uchun kalit so\'zni aytib bering',
        ),
      );
    } else {
      await _speakWithSync(
        'Summa aniqlanmadi. Iltimos, qaytadan aytib bering. Masalan: yuz ming so\'m',
      );
      await startListening();
    }
  }

  String _extractAmount(String text) {
    text = text.toLowerCase();

    final numberWords = {
      'nol': 0,
      'bir': 1,
      'ikki': 2,
      'uch': 3,
      'to\'rt': 4,
      'tort': 4,
      'besh': 5,
      'olti': 6,
      'yetti': 7,
      'sakkiz': 8,
      'to\'qqiz': 9,
      'toqqiz': 9,
      'on': 10,
      'yigirma': 20,
      'o\'ttiz': 30,
      'ottiz': 30,
      'qirq': 40,
      'ellik': 50,
      'oltmish': 60,
      'yetmish': 70,
      'sakson': 80,
      'to\'qson': 90,
      'toqsan': 90,
    };

    final multipliers = {
      'yuz': 100,
      'ming': 1000,
      'million': 1000000,
      'milliard': 1000000000,
    };

    final words = text.split(RegExp(r'\s+'));
    int total = 0;
    int current = 0;

    for (var word in words) {
      if (numberWords.containsKey(word)) {
        current += numberWords[word]!;
      } else if (multipliers.containsKey(word)) {
        int multiplier = multipliers[word]!;
        if (current == 0) current = 1;
        total += current * multiplier;
        current = 0;
      } else if (RegExp(r'^\d+$').hasMatch(word)) {
        current += int.parse(word);
      }
    }

    total += current;

    return total > 0 ? total.toString() : '';
  }

  // Summani ovozli takrorlash uchun formatlash (qo'shimcha)
  String _formatAmountWithSpaces(String amount) {
    String formatted = '';
    int count = 0;
    for (int i = amount.length - 1; i >= 0; i--) {
      formatted = amount[i] + formatted;
      count++;
      if (count % 3 == 0 && i != 0) {
        formatted = ' ' + formatted;
      }
    }
    return formatted;
  }

  Future<void> _performTransfer(Contact contact, String amount) async {
    emit(
      VoiceTransferProcessingState(
        contact: contact,
        amount: amount,
        statusMessage: 'O\'tkazma amalga oshirilmoqda...',
        isSpeaking: true,
      ),
    );
    await ApiService().paymentToContact(
      contact.name.first.toString(),
      contact.phones.first.number.toString(),
      int.tryParse(amount)!,
    ); // Imitatsiya qilish uchun delay
    await Future.delayed(const Duration(seconds: 2));

    await _speakWithSync(
      'O\'tkazma muvaffaqiyatli amalga oshirildi. Yangi o\'tkazma uchun kimga o\'tkazmoqchisiz?',
    );
    emit(
      VoiceTransferRecipientState(
        statusMessage: 'Yangi o\'tkazma uchun kimga o\'tkazmoqchisiz?',
      ),
    );
  }

  Future<void> _speakWithSync(String text) async {
    if (_isSpeaking) return;

    _isSpeaking = true;
    emit(state.copyWith(isSpeaking: true));

    try {
      await _tts.speak(text);
    } catch (e) {
      emit(
        VoiceTransferErrorState(
          errorMessage: 'Ovozli javob berishda xatolik',
          statusMessage: 'Ovozli javob berishda xatolik yuz berdi',
          isSpeaking: false,
          isProcessing: false,
        ),
      );
    } finally {
      _isSpeaking = false;
      emit(state.copyWith(isSpeaking: false));
    }
  }

  void reset() {
    _isSpeaking = false;
    emit(VoiceTransferInitial());
    initialize(); // Qayta initsializatsiya qilish
  }
}
