import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  GenerativeModel? _model;
  ChatSession? _chat;
  final _storage = const FlutterSecureStorage();

  /// Initialize the AI service with a system prompt and Gemini API key
  /// 
  /// The API key is read from secure storage first, then falls back to
  /// environment variable if not found in storage.
  Future<void> init(String systemPrompt) async {
    // Read key from secure storage, fallback to environment
    final apiKey = await _storage.read(key: 'gemini_api_key') ??
        const String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty) {
      throw Exception(
        'Gemini API key not found. '
        'Set GEMINI_API_KEY environment variable or store in secure storage.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    // Start a fresh chat session (holds history internally)
    _chat = _model!.startChat();
  }

  /// Send a message and get a response
  /// 
  /// Returns the text response from the Gemini model.
  /// Throws if the service is not initialized.
  Future<String> sendMessage(String message) async {
    if (_chat == null) throw Exception('AiService not initialized. Call init() first.');

    final response = await _chat!.sendMessage(Content.text(message));
    return response.text ?? 'No response';
  }

  /// Stream a message response for better UX with long responses
  /// 
  /// Yields text chunks as they arrive from the Gemini API.
  /// Throws if the service is not initialized.
  Stream<String> sendMessageStreamed(String message) async* {
    if (_chat == null) throw Exception('AiService not initialized. Call init() first.');

    final stream = _chat!.sendMessageStream(Content.text(message));
    await for (final chunk in stream) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  /// Reset the chat session to start a new conversation
  void resetChat() {
    if (_model != null) {
      _chat = _model!.startChat();
    }
  }

  /// Store the Gemini API key in secure storage
  /// 
  /// Call this during app initialization or when the user provides their key.
  Future<void> storeApiKey(String apiKey) async {
    await _storage.write(key: 'gemini_api_key', value: apiKey);
  }

  /// Retrieve the stored API key (for verification purposes)
  Future<String?> getStoredApiKey() async {
    return await _storage.read(key: 'gemini_api_key');
  }

  /// Clear the stored API key and reset the service
  Future<void> clear() async {
    await _storage.delete(key: 'gemini_api_key');
    _model = null;
    _chat = null;
  }
}