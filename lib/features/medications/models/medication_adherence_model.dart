class MedicationAdherenceModel {
  final String id;
  final String uid;
  final String medicationId;
  final String medicationName;
  final DateTime date;
  final int totalDoses; // Total scheduled doses for the day
  final int takenDoses; // Doses actually taken
  final int missedDoses; // Doses missed
  final int lateDoses; // Doses taken late
  final int missedStreak; // Current streak of missed doses
  final double adherenceScore; // 0-100 percentage
  final DateTime createdAt;

  const MedicationAdherenceModel({
    required this.id,
    required this.uid,
    required this.medicationId,
    required this.medicationName,
    required this.date,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.lateDoses,
    required this.missedStreak,
    required this.adherenceScore,
    required this.createdAt,
  });

  /// Calculate adherence score (percentage of doses taken on time)
  static double calculateScore({
    required int totalDoses,
    required int takenDoses,
    required int lateDoses,
  }) {
    if (totalDoses == 0) return 100.0;
    // On-time doses count as 100%, late doses count as 50%
    final score = ((takenDoses - lateDoses) + (lateDoses * 0.5)) / totalDoses * 100;
    return score.clamp(0, 100);
  }

  /// Get adherence status
  String getStatus() {
    if (adherenceScore >= 90) return 'Excellent';
    if (adherenceScore >= 75) return 'Good';
    if (adherenceScore >= 50) return 'Fair';
    return 'Poor';
  }

  /// Get adherence color indicator (for UI)
  String getColorStatus() {
    if (adherenceScore >= 90) return 'excellent'; // Green
    if (adherenceScore >= 75) return 'good'; // Light green
    if (adherenceScore >= 50) return 'fair'; // Yellow
    return 'poor'; // Red
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'date': date.toIso8601String(),
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
      'missedDoses': missedDoses,
      'lateDoses': lateDoses,
      'missedStreak': missedStreak,
      'adherenceScore': adherenceScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicationAdherenceModel.fromMap(Map<String, dynamic> map) {
    return MedicationAdherenceModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      medicationId: map['medicationId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      totalDoses: map['totalDoses'] ?? 0,
      takenDoses: map['takenDoses'] ?? 0,
      missedDoses: map['missedDoses'] ?? 0,
      lateDoses: map['lateDoses'] ?? 0,
      missedStreak: map['missedStreak'] ?? 0,
      adherenceScore: (map['adherenceScore'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  MedicationAdherenceModel copyWith({
    String? id,
    String? uid,
    String? medicationId,
    String? medicationName,
    DateTime? date,
    int? totalDoses,
    int? takenDoses,
    int? missedDoses,
    int? lateDoses,
    int? missedStreak,
    double? adherenceScore,
    DateTime? createdAt,
  }) {
    return MedicationAdherenceModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      date: date ?? this.date,
      totalDoses: totalDoses ?? this.totalDoses,
      takenDoses: takenDoses ?? this.takenDoses,
      missedDoses: missedDoses ?? this.missedDoses,
      lateDoses: lateDoses ?? this.lateDoses,
      missedStreak: missedStreak ?? this.missedStreak,
      adherenceScore: adherenceScore ?? this.adherenceScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
