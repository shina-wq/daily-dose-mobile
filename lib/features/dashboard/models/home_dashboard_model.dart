class HomeDashboardModel {
  const HomeDashboardModel({
    required this.userName,
    required this.userInitials,
    required this.aiInsight,
    required this.preVisitSummary,
    required this.healthScore,
    required this.adherencePercent,
    required this.adherenceSubtitle,
    required this.nextAppointmentDoctor,
    required this.nextAppointmentLabel,
    required this.hasUnreadNotifications,
    required this.medications,
  });

  final String userName;
  final String userInitials;
  final String aiInsight;
  final PreVisitSummaryModel preVisitSummary;
  final int healthScore;
  final int adherencePercent;
  final String adherenceSubtitle;
  final String nextAppointmentDoctor;
  final String nextAppointmentLabel;
  final bool hasUnreadNotifications;
  final List<HomeMedicationItem> medications;

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    final user = _stringKeyedMap(json['user']);
    final quickStats = _stringKeyedMap(json['quickStats']);
    final nextAppointment = _stringKeyedMap(quickStats['nextAppointment']);
    final preVisitSummaryJson = _stringKeyedMap(json['preVisitSummary']);
    final notifications = _stringKeyedMap(json['notifications']);
    final rawMedications = (json['medications'] as List?) ?? const [];

    return HomeDashboardModel(
      userName: (user['name'] as String?)?.trim().isNotEmpty == true
          ? (user['name'] as String).trim()
          : 'Friend',
      userInitials: (user['initials'] as String?)?.trim().isNotEmpty == true
          ? (user['initials'] as String).trim().toUpperCase()
          : 'DD',
      aiInsight: (json['aiInsight'] as String?)?.trim().isNotEmpty == true
          ? (json['aiInsight'] as String).trim()
          : 'No insight available right now.',
        preVisitSummary: PreVisitSummaryModel.fromJson(preVisitSummaryJson),
      healthScore: (quickStats['healthScore'] as num?)?.round() ?? 0,
      adherencePercent: (quickStats['adherencePercent'] as num?)?.round() ?? 0,
      adherenceSubtitle: (quickStats['adherenceSubtitle'] as String?) ?? 'No data',
      nextAppointmentDoctor:
          (nextAppointment['doctorName'] as String?) ?? 'No upcoming visit',
      nextAppointmentLabel:
          (nextAppointment['label'] as String?) ?? 'No upcoming appointments',
      hasUnreadNotifications: notifications['hasUnread'] as bool? ?? false,
      medications: rawMedications
          .whereType<Map<String, dynamic>>()
          .map(HomeMedicationItem.fromJson)
          .toList(),
    );
  }

  static Map<String, dynamic> _stringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }
}

    class PreVisitSummaryModel {
      const PreVisitSummaryModel({
        required this.title,
        required this.overview,
        required this.medications,
        required this.symptoms,
        required this.missedDoses,
        required this.insights,
        required this.trends,
        required this.suggestedQuestions,
      });

      final String title;
      final String overview;
      final List<String> medications;
      final List<String> symptoms;
      final int missedDoses;
      final List<String> insights;
      final List<String> trends;
      final List<String> suggestedQuestions;

      factory PreVisitSummaryModel.fromJson(Map<String, dynamic> json) {
        List<String> parseList(String key, {List<String> fallback = const []}) {
          final raw = (json[key] as List?) ?? const [];
          final parsed = raw
              .whereType<String>()
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList();
          return parsed.isNotEmpty ? parsed : fallback;
        }

        return PreVisitSummaryModel(
          title: (json['title'] as String?)?.trim().isNotEmpty == true
              ? (json['title'] as String).trim()
              : 'Pre-Visit Summary',
          overview: (json['overview'] as String?)?.trim().isNotEmpty == true
              ? (json['overview'] as String).trim()
              : 'Your pre-visit summary is ready to review.',
          medications: parseList('medications', fallback: const ['No active medications found']),
          symptoms: parseList('symptoms', fallback: const ['No symptom data available']),
          missedDoses: (json['missedDoses'] as num?)?.round() ?? 0,
          insights: parseList('insights', fallback: const ['Not enough data yet to build insights.']),
          trends: parseList('trends', fallback: const ['Not enough data yet to identify trends.']),
          suggestedQuestions: parseList(
            'suggestedQuestions',
            fallback: const ['What should I ask during this visit?'],
          ),
        );
      }
    }

class HomeMedicationItem {
  const HomeMedicationItem({
    required this.id,
    required this.medicationId,
    required this.name,
    required this.dosage,
    required this.details,
    required this.status,
    required this.isTaken,
  });

  final String id;
  final String medicationId;
  final String name;
  final String dosage;
  final String details;
  final String status;
  final bool isTaken;

  factory HomeMedicationItem.fromJson(Map<String, dynamic> json) {
    return HomeMedicationItem(
      id: (json['id'] as String?) ?? '',
      medicationId: (json['medicationId'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Medication',
      dosage: (json['dosage'] as String?) ?? '',
      details: (json['details'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      isTaken: json['isTaken'] as bool? ?? false,
    );
  }
}