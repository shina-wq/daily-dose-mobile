enum DoseStatus {
  pending, // Not yet taken
  taken, // Taken on time
  late, // Taken but after the scheduled time
  missed, // Not taken
}

class MedicationDoseModel {
  final String id;
  final String uid;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime? takenTime; // Actual time when taken
  final DoseStatus status;
  final String? notes;
  final DateTime createdAt;

  const MedicationDoseModel({
    required this.id,
    required this.uid,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  /// Check if dose was taken late (more than 15 minutes after scheduled time)
  bool isLate() {
    if (takenTime == null) return false;
    final difference = takenTime!.difference(scheduledTime);
    return difference.inMinutes > 15;
  }

  /// Get hours since dose should have been taken
  int hoursSinceMissed() {
    if (status != DoseStatus.missed) return 0;
    return DateTime.now().difference(scheduledTime).inHours;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicationDoseModel.fromMap(Map<String, dynamic> map) {
    return MedicationDoseModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      medicationId: map['medicationId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      dosage: map['dosage'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime'] ?? DateTime.now().toIso8601String()),
      takenTime: map['takenTime'] != null ? DateTime.parse(map['takenTime']) : null,
      status: _parseStatus(map['status']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static DoseStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return DoseStatus.pending;
    try {
      return DoseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusStr,
        orElse: () => DoseStatus.pending,
      );
    } catch (_) {
      return DoseStatus.pending;
    }
  }

  MedicationDoseModel copyWith({
    String? id,
    String? uid,
    String? medicationId,
    String? medicationName,
    String? dosage,
    DateTime? scheduledTime,
    DateTime? takenTime,
    DoseStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationDoseModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
