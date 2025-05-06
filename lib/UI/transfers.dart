import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ishlatilmayapti, lekin qoldirdim, kerak bo'lib qolar.
import '../bloc/voice_cubit.dart'; // To'g'ri nom
import '../bloc/voice_state.dart'; // To'g'ri nom
import '../service/speech_to_text_service.dart';
import '../service/text_to_speech_service.dart';

class VoiceTransferUI extends StatelessWidget {
  final TextToSpeechService _tts;
  final SpeechToTextService _stt;

  const VoiceTransferUI({
    Key? key,
    required TextToSpeechService tts,
    required SpeechToTextService stt,
  }) : _tts = tts,
       _stt = stt,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        return BlocProvider(
          create:
              (context) => VoiceTransferCubit(_tts, _stt, prefs)..initialize(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Ovozli O\'tkazmalar'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed:
                      () => _tts.speak(
                        'Bu ovoz orqali pul o\'tkazish tizimi. Mikrofon tugmasini bosib, kerakli buyruqlarni aytib bering',
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<VoiceTransferCubit>().reset(),
                  tooltip: 'Qayta boshlash',
                ),
              ],
            ),
            body: const VoiceTransferView(),
          ),
        );
      },
    );
  }
}

class VoiceTransferView extends StatelessWidget {
  const VoiceTransferView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStatusCard(context),
          const SizedBox(height: 20),
          _buildProcessingIndicator(context),
          _buildContactInfo(context),
          _buildAmountInfo(context),
          const Spacer(),
          _buildMicrophoneButton(context),
          const SizedBox(height: 20),
          _buildRecognizedText(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return BlocBuilder<VoiceTransferCubit, VoiceTransferState>(
      builder: (context, state) {
        Color cardColor = Theme.of(context).cardColor;
        if (state.errorMessage != null) {
          cardColor = Colors.red[100]!;
        } else if (state.isProcessing) {
          cardColor = Colors.blue[50]!;
        } else if (state.isListening) {
          cardColor = Colors.green[50]!;
        }

        return Card(
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (state.isProcessing && !state.isListening)
                  const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  state.statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessingIndicator(BuildContext context) {
    return BlocBuilder<VoiceTransferCubit, VoiceTransferState>(
      builder: (context, state) {
        return Visibility(
          visible: state.isProcessing && !state.isListening,
          child: const LinearProgressIndicator(),
        );
      },
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return BlocBuilder<VoiceTransferCubit, VoiceTransferState>(
      builder: (context, state) {
        final contact = state.selectedContact;
        if (contact == null) return const SizedBox();

        return Card(
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Kontakt:'),
            subtitle: Text(
              contact.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountInfo(BuildContext context) {
    return BlocBuilder<VoiceTransferCubit, VoiceTransferState>(
      builder: (context, state) {
        final amount = state.amount; // Use displayedAmount
        if (amount == null) return const SizedBox();

        return Card(
          child: ListTile(
            leading: const Icon(Icons.money, color: Colors.green),
            title: const Text('Summa:'),
            subtitle: Text(
              '$amount so\'m', // Display formatted amount
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicrophoneButton(BuildContext context) {
    return BlocBuilder<VoiceTransferCubit, VoiceTransferState>(
      builder: (context, state) {
        final isProcessing = state.isProcessing && !state.isListening;

        return FloatingActionButton.extended(
          onPressed:
              isProcessing
                  ? null
                  : () {
                    if (state.isListening) {
                      context.read<VoiceTransferCubit>().stopListening();
                    } else {
                      context.read<VoiceTransferCubit>().startListening();
                    }
                  },
          label: Text(
            state.isListening
                ? 'To\'xtatish'
                : isProcessing
                ? 'Jarayonda...'
                : 'Gapiring',
          ),
          icon: Icon(
            state.isListening
                ? Icons.mic_off
                : isProcessing
                ? Icons.hourglass_bottom
                : Icons.mic,
          ),
          backgroundColor:
              state.isListening
                  ? Colors.red
                  : isProcessing
                  ? Colors.grey
                  : Colors.blue,
        );
      },
    );
  }

  Widget _buildRecognizedText(BuildContext context) {
    return BlocBuilder<VoiceTransferCubit, VoiceTransferState>(
      builder: (context, state) {
        if (state.recognizedText.isEmpty) return const SizedBox();

        return Column(
          children: [
            const Text('Tushungan matn:', style: TextStyle(color: Colors.grey)),
            Text(
              state.recognizedText,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
