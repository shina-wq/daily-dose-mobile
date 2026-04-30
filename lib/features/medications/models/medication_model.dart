class MedicationModel {
  final String id;
  final String uid;
  final String name;
  final String dosage; // e.g., "500mg", "2 tablets"
  final String frequency; // e.g., "once daily", "twice daily", "every 6 hours"
  final List<String> timeSlots; // e.g., ["08:00", "20:00"]
  final String? reason; // Why the medication is prescribed
  final String? prescribedBy;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<String> sideEffects;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MedicationModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timeSlots,
    this.reason,
    this.prescribedBy,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.sideEffects = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if medication should be taken today
  bool shouldBeTakenToday(DateTime today) {
    if (!isActive) return false;
    if (startDate != null && today.isBefore(startDate!)) return false;
    if (endDate != null && today.isAfter(endDate!)) return false;
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'timeSlots': timeSlots,
      'reason': reason,
      'prescribedBy': prescribedBy,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'sideEffects': sideEffects,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      timeSlots: List<String>.from(map['timeSlots'] ?? []),
      reason: map['reason'],
      prescribedBy: map['prescribedBy'],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isActive: map['isActive'] ?? true,
      sideEffects: List<String>.from(map['sideEffects'] ?? []),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  MedicationModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? timeSlots,
    String? reason,
    String? prescribedBy,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<String>? sideEffects,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      timeSlots: timeSlots ?? this.timeSlots,
      reason: reason ?? this.reason,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      sideEffects: sideEffects ?? this.sideEffects,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
