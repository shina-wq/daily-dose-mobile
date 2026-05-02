import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.appointmentDateTime,
    required this.durationMinutes,
    required this.visitType,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.meetingLink,
    this.avatarLabel,
    this.isAiSummaryEnabled = true,
    this.completionNotes,
    this.completedAt,
  });

  final String id;
  final String doctorName;
  final String specialty;
  final DateTime appointmentDateTime;
  final int durationMinutes;
  final String visitType;
  final String reason;
  final String status;
  final String? location;
  final String? meetingLink;
  final String? avatarLabel;
  final bool isAiSummaryEnabled;
  final String? completionNotes;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == 'completed';

  bool get isCancelled => status == 'cancelled';

  AppointmentModel copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    DateTime? appointmentDateTime,
    int? durationMinutes,
    String? visitType,
    String? reason,
    String? status,
    String? location,
    String? meetingLink,
    String? avatarLabel,
    bool? isAiSummaryEnabled,
    String? completionNotes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      visitType: visitType ?? this.visitType,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      avatarLabel: avatarLabel ?? this.avatarLabel,
      isAiSummaryEnabled: isAiSummaryEnabled ?? this.isAiSummaryEnabled,
      completionNotes: completionNotes ?? this.completionNotes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime.toUtc()),
      'durationMinutes': durationMinutes,
      'visitType': visitType,
      'reason': reason,
      'status': status,
      'location': location,
      'meetingLink': meetingLink,
      'avatarLabel': avatarLabel,
      'isAiSummaryEnabled': isAiSummaryEnabled,
      'completionNotes': completionNotes,
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!.toUtc()),
      'createdAt': Timestamp.fromDate(createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(updatedAt.toUtc()),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: map['id'] as String? ?? id,
      doctorName: map['doctorName'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      appointmentDateTime: _dateFromMap(map['appointmentDateTime']) ?? DateTime.now(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 30,
      visitType: map['visitType'] as String? ?? 'Telehealth',
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? 'upcoming',
      location: map['location'] as String?,
      meetingLink: map['meetingLink'] as String?,
      avatarLabel: map['avatarLabel'] as String?,
      isAiSummaryEnabled: map['isAiSummaryEnabled'] as bool? ?? true,
      completionNotes: map['completionNotes'] as String?,
      completedAt: _dateFromMap(map['completedAt']),
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