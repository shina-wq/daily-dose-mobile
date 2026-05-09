import 'package:daily_dose_mobile/core/providers/ai_assistant_provider.dart';
import 'package:daily_dose_mobile/core/providers/auth_provider.dart';
import 'package:daily_dose_mobile/features/ai_assistant/screens/ai_chat_screen.dart';
import 'package:daily_dose_mobile/services/ai_service.dart';
import 'package:daily_dose_mobile/services/assistant_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAiService extends AiService {
  FakeAiService({this.storedApiKey});

  final String? storedApiKey;

  @override
  Future<String?> getStoredApiKey() async => storedApiKey;
}

class FakeAssistantService extends AssistantService {
  FakeAssistantService(this.fakeAi, {this.throwOnInitialize = false})
      : super(fakeAi, firestore: FakeFirebaseFirestore());

  final FakeAiService fakeAi;
  final bool throwOnInitialize;
  String? initializedForUserId;
  final List<String> prompts = <String>[];

  @override
  Future<void> initializeForUser(String userId) async {
    if (throwOnInitialize) {
      throw Exception('Gemini API key not found. Set GEMINI_API_KEY environment variable or store in secure storage.');
    }
    initializedForUserId = userId;
  }

  @override
  Stream<String> sendMessageStreamed(String message) async* {
    prompts.add(message);
    yield 'This looks relevant to your data. ';
    yield "I'm not a doctor, but this can help you prepare for your visit.";
  }

  @override
  Future<String> sendMessage(String message) async {
    prompts.add(message);
    return "I'm not a doctor, but here is a safe next step for your profile.";
  }
}

void main() {
  User testUser() => MockUser(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

  Widget buildTestApp({
    required FakeAiService aiService,
    required FakeAssistantService assistantService,
    required User user,
  }) {
    return ProviderScope(
      overrides: [
        aiServiceProvider.overrideWithValue(aiService),
        assistantServiceProvider.overrideWithValue(assistantService),
        authStateProvider.overrideWithValue(AsyncValue.data(user)),
      ],
      child: const MaterialApp(
        home: AiChatScreen(),
      ),
    );
  }

  group('AiChatScreen', () {
    testWidgets('shows initialization error when API key is missing', (tester) async {
      final aiService = FakeAiService(storedApiKey: null);
      final assistantService = FakeAssistantService(
        aiService,
        throwOnInitialize: true,
      );

      await tester.pumpWidget(
        buildTestApp(
          aiService: aiService,
          assistantService: assistantService,
          user: testUser(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('Failed to initialize assistant:'),
        findsOneWidget,
      );
      expect(assistantService.initializedForUserId, isNull);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('initializes and sends suggested prompt when API key is present', (tester) async {
      final aiService = FakeAiService(storedApiKey: 'fake-key');
      final assistantService = FakeAssistantService(aiService);

      await tester.pumpWidget(
        buildTestApp(
          aiService: aiService,
          assistantService: assistantService,
          user: testUser(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(assistantService.initializedForUserId, equals('test-uid-123'));

      await tester.tap(find.text('Analyze my recent health trends'));
      await tester.pumpAndSettle();

      expect(assistantService.prompts, isNotEmpty);
      expect(
        assistantService.prompts.first,
        contains('analyze my recent health logs'),
      );
      expect(find.textContaining("I'm not a doctor"), findsOneWidget);
    });

    testWidgets('submitting text sends a message and renders response', (tester) async {
      final aiService = FakeAiService(storedApiKey: 'fake-key');
      final assistantService = FakeAssistantService(aiService);

      await tester.pumpWidget(
        buildTestApp(
          aiService: aiService,
          assistantService: assistantService,
          user: testUser(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'What should I ask in my appointment?',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(
        assistantService.prompts,
        contains('What should I ask in my appointment?'),
      );
      expect(find.textContaining("I'm not a doctor"), findsOneWidget);
    });
  });
}
