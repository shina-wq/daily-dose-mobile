import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_dose_mobile/services/ai_service.dart';
import 'package:daily_dose_mobile/services/assistant_service.dart';

/// Provider for the AiService singleton
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// Provider for the AssistantService singleton
final assistantServiceProvider = Provider<AssistantService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AssistantService(aiService);
});

/// Async provider to initialize the assistant with user context
final assistantInitializationProvider = FutureProvider.family<void, String>(
  (ref, userId) async {
    final assistantService = ref.watch(assistantServiceProvider);
    await assistantService.initializeForUser(userId);
  },
);

/// Provider for managing the current conversation state
final currentConversationProvider = NotifierProvider<ConversationStateNotifier,
    ConversationState>(ConversationStateNotifier.new);

/// State for the current conversation
class ConversationState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Model for a single chat message
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Notifier for managing conversation state
class ConversationStateNotifier extends Notifier<ConversationState> {
  late final AssistantService _assistantService;

  @override
  ConversationState build() {
    _assistantService = ref.watch(assistantServiceProvider);
    return ConversationState();
  }

  /// Send a message and get a response (streaming)
  Future<void> sendMessageStreamed(String message) async {
    // Add user message
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: message, isUser: true),
      ],
      isLoading: true,
      error: null,
    );

    try {
      final buffer = StringBuffer();

      // Stream the response
      await for (final chunk
          in _assistantService.sendMessageStreamed(message)) {
        buffer.write(chunk);
      }

      // Add assistant message once stream is complete
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(text: buffer.toString(), isUser: false),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Send a message and get a response (non-streaming)
  Future<void> sendMessage(String message) async {
    // Add user message
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: message, isUser: true),
      ],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _assistantService.sendMessage(message);

      // Add assistant message
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(text: response, isUser: false),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear the conversation
  void clearConversation() {
    _assistantService.resetConversation();
    state = ConversationState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}
