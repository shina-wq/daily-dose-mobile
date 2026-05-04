class HomeDashboardModel {
  const HomeDashboardModel({
    required this.userName,
    required this.userInitials,
    required this.aiInsight,
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
  final int healthScore;
  final int adherencePercent;
  final String adherenceSubtitle;
  final String nextAppointmentDoctor;
  final String nextAppointmentLabel;
  final bool hasUnreadNotifications;
  final List<HomeMedicationItem> medications;

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final quickStats = (json['quickStats'] as Map<String, dynamic>?) ?? const {};
    final nextAppointment =
        (quickStats['nextAppointment'] as Map<String, dynamic>?) ?? const {};
    final notifications =
        (json['notifications'] as Map<String, dynamic>?) ?? const {};
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