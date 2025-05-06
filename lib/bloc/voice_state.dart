import 'package:flutter_contacts/flutter_contacts.dart';

abstract class VoiceTransferState {
  final bool isProcessing;
  final bool isListening;
  final bool isSpeaking;
  final String statusMessage;
  final String? errorMessage;
  final String recognizedText;
  final Contact? selectedContact;
  final String? amount;
  final String? selectedCard;

  const VoiceTransferState({
    this.isProcessing = false,
    this.isListening = false,
    this.isSpeaking = false,
    required this.statusMessage,
    this.errorMessage,
    this.recognizedText = '',
    this.selectedContact,
    this.amount,
    this.selectedCard,
  });

  VoiceTransferState copyWith({
    bool? isProcessing,
    bool? isListening,
    bool? isSpeaking,
    String? statusMessage,
    String? errorMessage,
    String? recognizedText,
    Contact? selectedContact,
    String? amount,
    String? selectedCard,
  });
}

class VoiceTransferInitial extends VoiceTransferState {
  const VoiceTransferInitial({
    bool isProcessing = false,
    bool isListening = false,
    bool isSpeaking = false,
    String statusMessage = 'Kimga o\'tkazmoqchisiz? Ismini aytib bering',
    String? errorMessage,
    String recognizedText = '',
  }) : super(
         isProcessing: isProcessing,
         isListening: isListening,
         isSpeaking: isSpeaking,
         statusMessage: statusMessage,
         errorMessage: errorMessage,
         recognizedText: recognizedText,
       );

  @override
  VoiceTransferInitial copyWith({
    bool? isProcessing,
    bool? isListening,
    bool? isSpeaking,
    String? statusMessage,
    String? errorMessage,
    String? recognizedText,
    Contact? selectedContact,
    String? amount,
    String? selectedCard,
  }) {
    return VoiceTransferInitial(
      isProcessing: isProcessing ?? this.isProcessing,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      recognizedText: recognizedText ?? this.recognizedText,
    );
  }
}

class VoiceTransferRecipientState extends VoiceTransferState {
  const VoiceTransferRecipientState({
    bool isProcessing = false,
    bool isListening = false,
    bool isSpeaking = false,
    required String statusMessage,
    String? errorMessage,
    String recognizedText = '',
  }) : super(
         isProcessing: isProcessing,
         isListening: isListening,
         isSpeaking: isSpeaking,
         statusMessage: statusMessage,
         errorMessage: errorMessage,
         recognizedText: recognizedText,
       );

  @override
  VoiceTransferRecipientState copyWith({
    bool? isProcessing,
    bool? isListening,
    bool? isSpeaking,
    String? statusMessage,
    String? errorMessage,
    String? recognizedText,
    Contact? selectedContact,
    String? amount,
    String? selectedCard,
  }) {
    return VoiceTransferRecipientState(
      isProcessing: isProcessing ?? this.isProcessing,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      recognizedText: recognizedText ?? this.recognizedText,
    );
  }
}

class VoiceTransferAmountState extends VoiceTransferState {
  final Contact selectedContact;

  const VoiceTransferAmountState({
    required this.selectedContact,
    bool isProcessing = false,
    bool isListening = false,
    bool isSpeaking = false,
    required String statusMessage,
    String? errorMessage,
    String recognizedText = '',
    String? amount,
  }) : super(
         isProcessing: isProcessing,
         isListening: isListening,
         isSpeaking: isSpeaking,
         statusMessage: statusMessage,
         errorMessage: errorMessage,
         recognizedText: recognizedText,
         selectedContact: selectedContact,
         amount: amount,
       );

  @override
  VoiceTransferAmountState copyWith({
    bool? isProcessing,
    bool? isListening,
    bool? isSpeaking,
    String? statusMessage,
    String? errorMessage,
    String? recognizedText,
    Contact? selectedContact,
    String? amount,
    String? selectedCard,
  }) {
    return VoiceTransferAmountState(
      selectedContact: selectedContact ?? this.selectedContact,
      isProcessing: isProcessing ?? this.isProcessing,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      recognizedText: recognizedText ?? this.recognizedText,
      amount: amount ?? this.amount,
    );
  }
}

class VoiceTransferConfirmationState extends VoiceTransferState {
  final Contact selectedContact;
  final String amount;

  const VoiceTransferConfirmationState({
    required this.selectedContact,
    required this.amount,
    bool isProcessing = false,
    bool isListening = false,
    bool isSpeaking = false,
    required String statusMessage,
    String? errorMessage,
    String recognizedText = '',
  }) : super(
         isProcessing: isProcessing,
         isListening: isListening,
         isSpeaking: isSpeaking,
         statusMessage: statusMessage,
         errorMessage: errorMessage,
         recognizedText: recognizedText,
         selectedContact: selectedContact,
         amount: amount,
       );

  @override
  VoiceTransferConfirmationState copyWith({
    bool? isProcessing,
    bool? isListening,
    bool? isSpeaking,
    String? statusMessage,
    String? errorMessage,
    String? recognizedText,
    Contact? selectedContact,
    String? amount,
    String? selectedCard,
  }) {
    return VoiceTransferConfirmationState(
      selectedContact: selectedContact ?? this.selectedContact,
      amount: amount ?? this.amount,
      isProcessing: isProcessing ?? this.isProcessing,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      recognizedText: recognizedText ?? this.recognizedText,
    );
  }
}

class VoiceTransferProcessingState extends VoiceTransferState {
  final Contact contact;
  final String amount;

  const VoiceTransferProcessingState({
    required this.contact,
    required this.amount,
    bool isProcessing = true,
    bool isListening = false,
    bool isSpeaking = false,
    required String statusMessage,
    String? errorMessage,
    String recognizedText = '',
  }) : super(
         isProcessing: isProcessing,
         isListening: isListening,
         isSpeaking: isSpeaking,
         statusMessage: statusMessage,
         errorMessage: errorMessage,
         recognizedText: recognizedText,
         selectedContact: contact,
         amount: amount,
       );

  @override
  VoiceTransferProcessingState copyWith({
    bool? isProcessing,
    bool? isListening,
    bool? isSpeaking,
    String? statusMessage,
    String? errorMessage,
    String? recognizedText,
    Contact? selectedContact,
    String? amount,
    String? selectedCard,
  }) {
    return VoiceTransferProcessingState(
      contact: selectedContact ?? this.contact,
      amount: amount ?? this.amount,
      isProcessing: isProcessing ?? this.isProcessing,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      recognizedText: recognizedText ?? this.recognizedText,
    );
  }
}

class VoiceTransferErrorState extends VoiceTransferState {
  const VoiceTransferErrorState({
    required String? errorMessage,
    required String statusMessage,
    bool isProcessing = false,
    bool isListening = false,
    bool isSpeaking = false,
    String recognizedText = '',
  }) : super(
         errorMessage: errorMessage,
         statusMessage: statusMessage,
         isProcessing: isProcessing,
         isListening: isListening,
         isSpeaking: isSpeaking,
         recognizedText: recognizedText,
       );

  @override
  VoiceTransferErrorState copyWith({
    bool? isProcessing,
    bool? isListening,
    bool? isSpeaking,
    String? statusMessage,
    String? errorMessage,
    String? recognizedText,
    Contact? selectedContact,
    String? amount,
    String? selectedCard,
  }) {
    return VoiceTransferErrorState(
      errorMessage: errorMessage ?? this.errorMessage,
      statusMessage: statusMessage ?? this.statusMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      recognizedText: recognizedText ?? this.recognizedText,
    );
  }
}
