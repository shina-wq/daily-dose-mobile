import 'package:daily_dose_mobile/features/dashboard/models/home_dashboard_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeDashboardModel', () {
    test('parses a structured pre-visit summary payload', () {
      final model = HomeDashboardModel.fromJson({
        'user': {
          'name': 'Grace Hopper',
          'initials': 'GH',
        },
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

      expect(model.userName, 'Grace Hopper');
      expect(model.userInitials, 'GH');
      expect(model.preVisitSummary.title, 'Pre-Visit Summary for Dr. Patel');
      expect(model.preVisitSummary.medications, contains('Metformin (500mg)'));
      expect(model.preVisitSummary.symptoms, contains('Fatigue'));
      expect(model.preVisitSummary.missedDoses, 2);
      expect(model.preVisitSummary.insights, hasLength(3));
      expect(model.preVisitSummary.trends, hasLength(3));
      expect(model.preVisitSummary.suggestedQuestions, hasLength(4));
      expect(model.healthScore, 80);
      expect(model.hasUnreadNotifications, isTrue);
    });

    test('falls back cleanly when pre-visit summary data is minimal', () {
      final model = HomeDashboardModel.fromJson({
        'user': {},
        'quickStats': {},
        'notifications': {},
        'medications': const [],
      });

      expect(model.userName, 'Friend');
      expect(model.userInitials, 'DD');
      expect(model.preVisitSummary.title, 'Pre-Visit Summary');
      expect(model.preVisitSummary.overview, 'Your pre-visit summary is ready to review.');
      expect(model.preVisitSummary.medications, contains('No active medications found'));
      expect(model.preVisitSummary.symptoms, contains('No symptom data available'));
      expect(model.preVisitSummary.missedDoses, 0);
      expect(model.preVisitSummary.suggestedQuestions, isNotEmpty);
    });
  });
}
