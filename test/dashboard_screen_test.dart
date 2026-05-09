import 'package:daily_dose_mobile/core/providers/ai_assistant_provider.dart';
import 'package:daily_dose_mobile/core/providers/auth_provider.dart';
import 'package:daily_dose_mobile/core/navigation/app_router.dart';
import 'package:daily_dose_mobile/features/dashboard/models/home_dashboard_model.dart';
import 'package:daily_dose_mobile/features/dashboard/providers/home_provider.dart';
import 'package:daily_dose_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:daily_dose_mobile/features/dashboard/screens/pre_visit_summary_screen.dart';
import 'package:daily_dose_mobile/services/ai_service.dart';
import 'package:daily_dose_mobile/services/assistant_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SummarySmokeAiService extends AiService {
  @override
  Future<String?> getStoredApiKey() async => '';
}

class _SummarySmokeAssistantService extends AssistantService {
  _SummarySmokeAssistantService(AiService aiService)
      : super(aiService, firestore: FakeFirebaseFirestore());
}

HomeDashboardModel _sampleHomeModel() {
  return HomeDashboardModel.fromJson({
    'user': {'name': 'Grace Hopper', 'initials': 'GH'},
    'aiInsight': 'Adherence is at 80%. Latest logged symptom: Fatigue.',
    'preVisitSummary': {
      'title': 'Pre-Visit Summary for Dr. Patel',
      'overview': 'Grace Hopper\'s pre-visit summary pulls together medications, symptoms, and missed doses.',
      'medications': ['Metformin (500mg)', 'Amlodipine (10mg)'],
      'symptoms': ['Fatigue', 'Headache'],
      'missedDoses': 2,
      'insights': [
        'Adherence is 80% (good progress).',
        'Recent symptoms tracked: Fatigue, Headache.',
        '2 missed doses were detected and should be discussed.',
      ],
      'trends': [
        '2 medication reminders are visible for review.',
        'Symptoms are recurring across logs: Fatigue, Headache.',
        'Most recent symptom noted: Fatigue.',
      ],
      'suggestedQuestions': [
        'Could any of Metformin (500mg) be related to Fatigue?',
        'What should I watch for if Fatigue gets worse before my visit?',
        'How should I get back on track after 2 missed doses?',
        'What should I ask Dr. Patel about these symptoms and medications?',
      ],
    },
    'quickStats': {
      'healthScore': 80,
      'adherencePercent': 80,
      'adherenceSubtitle': 'Good progress',
      'nextAppointment': {
        'doctorName': 'Dr. Patel',
        'label': 'Tomorrow, 9:00 AM',
      },
    },
    'notifications': {'hasUnread': true},
    'medications': [
      {
        'id': 'dose-1',
        'medicationId': 'med-1',
        'name': 'Metformin',
        'dosage': '500mg',
        'details': '500mg • 8:00 AM',
        'status': 'pending',
        'isTaken': false,
      },
    ],
  });
}

void main() {
  testWidgets('dashboard renders a structured pre-visit summary', (tester) async {
    final home = _sampleHomeModel();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDashboardProvider.overrideWith((ref) async => home),
          backgroundTasksInitializerProvider.overrideWith((ref) async {}),
          aiServiceProvider.overrideWithValue(_SummarySmokeAiService()),
          assistantServiceProvider.overrideWithValue(
            _SummarySmokeAssistantService(_SummarySmokeAiService()),
          ),
        ],
        child: MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pre-Visit Summary for Dr. Patel'), findsOneWidget);
    expect(find.textContaining('medications, symptoms, and missed doses'), findsOneWidget);
    expect(find.text('MEDICATIONS'), findsWidgets);
    expect(find.text('SYMPTOMS'), findsWidgets);
    expect(find.text('INSIGHTS'), findsWidgets);
    expect(find.text('TRENDS'), findsWidgets);
    expect(find.text('SUGGESTED QUESTIONS'), findsWidgets);
    expect(find.textContaining('2 missed doses'), findsWidgets);
    expect(find.textContaining('What should I ask Dr. Patel'), findsOneWidget);
  });

  testWidgets('dashboard CTA opens dedicated pre-visit summary screen', (tester) async {
    final home = _sampleHomeModel();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDashboardProvider.overrideWith((ref) async => home),
          backgroundTasksInitializerProvider.overrideWith((ref) async {}),
          aiServiceProvider.overrideWithValue(_SummarySmokeAiService()),
          assistantServiceProvider.overrideWithValue(
            _SummarySmokeAssistantService(_SummarySmokeAiService()),
          ),
        ],
        child: MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('View Pre-Visit Summary'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Suggested Doctor Questions'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PreVisitSummaryScreen), findsOneWidget);
    expect(find.text('Suggested Doctor Questions'), findsOneWidget);
    expect(find.text('1. Could any of Metformin (500mg) be related to Fatigue?'), findsOneWidget);
  });
}
