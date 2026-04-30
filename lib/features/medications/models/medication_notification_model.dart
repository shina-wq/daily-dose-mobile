enum NotificationType {
  reminder, // Regular medication reminder
  missedDose, // Alert for missed dose
  streakWarning, // Warning for consecutive missed doses
  adherenceReport, // Daily/weekly adherence report
}

class MedicationNotificationModel {
  final String id;
  final String uid;
  final String? medicationId;
  final String? medicationName;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final bool isSent;
  final DateTime? sentTime;
  final bool isRead;
  final DateTime? readTime;
  final String? actionUrl; // Deep link or action URL
  final int missedStreak; // For streak warnings
  final DateTime createdAt;

  const MedicationNotificationModel({
    required this.id,
    required this.uid,
    this.medicationId,
    this.medicationName,
    required this.type,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.isSent = false,
    this.sentTime,
    this.isRead = false,
    this.readTime,
    this.actionUrl,
    this.missedStreak = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isSent': isSent,
      'sentTime': sentTime?.toIso8601String(),
      'isRead': isRead,
      'readTime': readTime?.toIso8601String(),
      'actionUrl': actionUrl,
      'missedStreak': missedStreak,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicationNotificationModel.fromMap(Map<String, dynamic> map) {
    return MedicationNotificationModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      medicationId: map['medicationId'],
      medicationName: map['medicationName'],
      type: _parseType(map['type']),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime'] ?? DateTime.now().toIso8601String()),
      isSent: map['isSent'] ?? false,
      sentTime: map['sentTime'] != null ? DateTime.parse(map['sentTime']) : null,
      isRead: map['isRead'] ?? false,
      readTime: map['readTime'] != null ? DateTime.parse(map['readTime']) : null,
      actionUrl: map['actionUrl'],
      missedStreak: map['missedStreak'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static NotificationType _parseType(String? typeStr) {
    if (typeStr == null) return NotificationType.reminder;
    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeStr,
        orElse: () => NotificationType.reminder,
      );
    } catch (_) {
      return NotificationType.reminder;
    }
  }

  MedicationNotificationModel copyWith({
    String? id,
    String? uid,
    String? medicationId,
    String? medicationName,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? scheduledTime,
    bool? isSent,
    DateTime? sentTime,
    bool? isRead,
    DateTime? readTime,
    String? actionUrl,
    int? missedStreak,
    DateTime? createdAt,
  }) {
    return MedicationNotificationModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isSent: isSent ?? this.isSent,
      sentTime: sentTime ?? this.sentTime,
      isRead: isRead ?? this.isRead,
      readTime: readTime ?? this.readTime,
      actionUrl: actionUrl ?? this.actionUrl,
      missedStreak: missedStreak ?? this.missedStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
