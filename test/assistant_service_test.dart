import 'package:daily_dose_mobile/services/ai_service.dart';
import 'package:daily_dose_mobile/services/assistant_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAiService extends AiService {
  String? initializedPrompt;
  final List<String> sentMessages = <String>[];

  @override
  Future<void> init(String systemPrompt) async {
    initializedPrompt = systemPrompt;
  }

  @override
  Future<String> sendMessage(String message) async {
    sentMessages.add(message);
    return "I'm not a doctor, but based on your profile this could be worth discussing with your clinician.";
  }

  @override
  Stream<String> sendMessageStreamed(String message) async* {
    sentMessages.add(message);
    yield 'Personalized insight for your current medications. ';
    yield "I'm not a doctor, but please confirm with your provider.";
  }
}

void main() {
  group('AssistantService', () {
    late FakeFirebaseFirestore firestore;
    late FakeAiService fakeAiService;
    late AssistantService assistantService;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      fakeAiService = FakeAiService();
      assistantService = AssistantService(
        fakeAiService,
        firestore: firestore,
      );
    });

    test('initializeForUser builds personalized prompt with user data and safety tone', () async {
      const userId = 'user-1';

      await firestore.collection('users').doc(userId).set({
        'name': 'Jane Doe',
        'allergies': ['Penicillin'],
      });

      await firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc('med-1')
          .set({'name': 'Metformin', 'isActive': true});

      await firestore
          .collection('users')
          .doc(userId)
          .collection('medications')
          .doc('med-2')
          .set({'name': 'Old Medication', 'active': false});

      await firestore
          .collection('users')
          .doc(userId)
          .collection('health_conditions')
          .doc('cond-1')
          .set({'name': 'Type 2 Diabetes'});

      await assistantService.initializeForUser(userId);

      final prompt = fakeAiService.initializedPrompt;
      expect(prompt, isNotNull);
      expect(prompt, contains('Name: Jane Doe'));
      expect(prompt, contains('Active Medications: Metformin'));
      expect(prompt, isNot(contains('Old Medication')));
      expect(prompt, contains('Health Conditions: Type 2 Diabetes'));
      expect(prompt, contains('Known Allergies: Penicillin'));

      expect(prompt, contains("I'm not a doctor"));
      expect(prompt, contains('Do not make up medical facts'));
      expect(
        prompt,
        contains('not a replacement for professional medical advice'),
      );
    });

    test('initializeForUser throws for missing user document', () async {
      await expectLater(
        () => assistantService.initializeForUser('missing-user'),
        throwsA(isA<Exception>()),
      );
    });

    test('sendMessageStreamed returns assistant output chunks', () async {
      final response = await assistantService
          .sendMessageStreamed('What should I ask my doctor?')
          .toList();

      expect(response, isNotEmpty);
      expect(response.join(), contains("I'm not a doctor"));
    });
  });
}
