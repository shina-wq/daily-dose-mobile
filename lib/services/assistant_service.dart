import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_dose_mobile/services/ai_service.dart';

class AssistantService {
  final AiService _aiService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AssistantService(this._aiService);

  /// Initialize the AI assistant with user context from Firestore
  /// 
  /// Fetches the user's health data (medications, allergies, conditions)
  /// and builds a personalized system prompt for the assistant.
  Future<void> initializeForUser(String userId) async {
    try {
      // Fetch user profile data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data() ?? {};

      // Fetch active medications
      final medsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .where('active', isEqualTo: true)
          .get();

      final medicationNames =
          medsSnapshot.docs.map((doc) => doc['name'] as String).toList();

      // Fetch health conditions if available
      final conditionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_conditions')
          .get();

      final conditions =
          conditionsSnapshot.docs.map((doc) => doc['name'] as String).toList();

      // Build the system prompt with user context
      final systemPrompt = _buildSystemPrompt(
        userName: userData['name'] ?? 'Friend',
        medications: medicationNames,
        conditions: conditions,
        allergies: (userData['allergies'] as List<dynamic>?)
                ?.cast<String>()
                .toList() ??
            [],
      );

      // Initialize the AI service with the personalized prompt
      await _aiService.init(systemPrompt);
    } catch (e) {
      throw Exception('Failed to initialize assistant: $e');
    }
  }

  /// Build a personalized system prompt based on user health data
  String _buildSystemPrompt({
    required String userName,
    required List<String> medications,
    required List<String> conditions,
    required List<String> allergies,
  }) {
    final medList = medications.isNotEmpty ? medications.join(', ') : 'No active medications';
    final conditionList =
        conditions.isNotEmpty ? conditions.join(', ') : 'No reported conditions';
    final allergyList =
        allergies.isNotEmpty ? allergies.join(', ') : 'No reported allergies';

    return '''You are a compassionate and knowledgeable health assistant for DailyDose, a personal health management app.

User Profile:
- Name: $userName
- Active Medications: $medList
- Health Conditions: $conditionList
- Known Allergies: $allergyList

Your role is to:
1. Provide supportive, empathetic health guidance
2. Help users understand their medications and conditions
3. Suggest lifestyle improvements and wellness tips
4. Remind users to take medications on time
5. Encourage regular check-ups with healthcare providers

Important Guidelines:
- ALWAYS recommend consulting a healthcare professional for urgent or serious concerns
- Never diagnose conditions or prescribe medications
- Be supportive and non-judgmental
- Provide evidence-based health information
- If asked about drug interactions, recommend checking with their pharmacist or doctor
- Acknowledge the user by name when appropriate to build rapport
- Keep responses concise and easy to understand

Remember: You are a support tool, not a replacement for professional medical advice.''';
  }

  /// Send a message to the assistant
  Future<String> sendMessage(String message) async {
    return await _aiService.sendMessage(message);
  }

  /// Stream a message response
  Stream<String> sendMessageStreamed(String message) async* {
    yield* _aiService.sendMessageStreamed(message);
  }

  /// Start a new conversation
  void resetConversation() {
    _aiService.resetChat();
  }

  /// Clear the assistant (logs user out or resets)
  Future<void> clear() async {
    await _aiService.clear();
  }
}
