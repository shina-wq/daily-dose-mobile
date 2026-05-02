import 'package:cloud_firestore/cloud_firestore.dart';

class HealthLogModel {
  const HealthLogModel({
    required this.id,
    required this.symptom,
    required this.severity,
    required this.loggedAt,
    required this.notes,
    required this.triggers,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String symptom;
  final String severity;
  final DateTime loggedAt;
  final String notes;
  final List<String> triggers;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthLogModel copyWith({
    String? id,
    String? symptom,
    String? severity,
    DateTime? loggedAt,
    String? notes,
    List<String>? triggers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthLogModel(
      id: id ?? this.id,
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
      loggedAt: loggedAt ?? this.loggedAt,
      notes: notes ?? this.notes,
      triggers: triggers ?? this.triggers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symptom': symptom,
      'severity': severity,
      'loggedAt': Timestamp.fromDate(loggedAt.toUtc()),
      'notes': notes,
      'triggers': triggers,
      'createdAt': Timestamp.fromDate(createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(updatedAt.toUtc()),
    };
  }

  factory HealthLogModel.fromMap(Map<String, dynamic> map, String id) {
    return HealthLogModel(
      id: map['id'] as String? ?? id,
      symptom: map['symptom'] as String? ?? '',
      severity: map['severity'] as String? ?? 'Moderate',
      loggedAt: _dateFromMap(map['loggedAt']) ?? DateTime.now(),
      notes: map['notes'] as String? ?? '',
      triggers: (map['triggers'] as List?)?.whereType<String>().toList() ?? const [],
      createdAt: _dateFromMap(map['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromMap(map['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _dateFromMap(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }

    return null;
  }
}