import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart' show Color;
import '../features/medications/models/medication_notification_model.dart';
import '../features/medications/models/medication_dose_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _notificationsCollection = 'medication_notifications';

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // iOS initialization
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Request iOS permissions
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _isInitialized = true;
  }

  // ==================== MEDICATION REMINDERS ====================

  /// Schedule medication reminder notifications
  Future<void> scheduleMedicationReminder(
    String uid,
    MedicationDoseModel dose,
  ) async {
    try {
      // Calculate the time to show the notification (5 minutes before scheduled time)
      final notificationTime = dose.scheduledTime.subtract(const Duration(minutes: 5));

      // Only schedule if the notification time is in the future
      if (notificationTime.isBefore(DateTime.now())) {
        return;
      }

      final notificationId = dose.id.hashCode;
      final message = 'Time to take ${dose.medicationName}';

      // Schedule local notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Medication Reminder',
        body: message,
        scheduledDate: tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Reminders to take your medications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            actions: [
              const AndroidNotificationAction(
                'mark_taken',
                'Mark as Taken',
                cancelNotification: true,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      // Store notification in Firestore
      final notification = MedicationNotificationModel(
        id: const Uuid().v4(),
        uid: uid,
        medicationId: dose.medicationId,
        medicationName: dose.medicationName,
        type: NotificationType.reminder,
        title: 'Medication Reminder',
        message: message,
        scheduledTime: notificationTime,
        isSent: true,
        sentTime: DateTime.now(),
        actionUrl: '/medications/${dose.medicationId}/dose/${dose.id}',
        createdAt: DateTime.now(),
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      print('Error scheduling medication reminder: $e');
    }
  }

  /// Schedule medication reminders for all pending doses
  Future<void> scheduleAllPendingReminders(String uid) async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('medication_doses')
          .where('status', isEqualTo: 'pending')
          .where('scheduledTime', isGreaterThanOrEqualTo: now)
          .where('scheduledTime', isLessThan: tomorrow.add(const Duration(days: 1)))
          .get();

      for (final doc in snapshot.docs) {
        final dose = MedicationDoseModel.fromMap(doc.data());
        await scheduleMedicationReminder(uid, dose);
      }
    } catch (e) {
      print('Error scheduling all pending reminders: $e');
    }
  }

  // ==================== MISSED DOSE ALERTS ====================

  /// Send notification for a missed dose
  Future<void> notifyMissedDose(String uid, MedicationDoseModel dose) async {
    try {
      final notificationId = (dose.id + '_missed').hashCode;
      final message = '${dose.medicationName} was not taken at ${_formatTime(dose.scheduledTime)}';

      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: 'Missed Dose Alert',
        body: message,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'missed_dose_alerts',
            'Missed Dose Alerts',
            channelDescription: 'Alerts for missed medication doses',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            color: const Color(0xFFEF4444), // Red color
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      // Store notification in Firestore
      final notification = MedicationNotificationModel(
        id: const Uuid().v4(),
        uid: uid,
        medicationId: dose.medicationId,
        medicationName: dose.medicationName,
        type: NotificationType.missedDose,
        title: 'Missed Dose Alert',
        message: message,
        scheduledTime: DateTime.now(),
        isSent: true,
        sentTime: DateTime.now(),
        actionUrl: '/medications/${dose.medicationId}/dose/${dose.id}',
        createdAt: DateTime.now(),
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      print('Error notifying missed dose: $e');
    }
  }

  // ==================== STREAK WARNINGS ====================

  /// Send notification for consecutive missed doses
  Future<void> notifyMissedDoseStreak(
    String uid,
    String medicationName,
    int streakDays,
  ) async {
    try {
      if (streakDays < 2) return; // Only notify for streaks of 2+ days

      final notificationId = (medicationName + '_streak').hashCode;
      String message;

      if (streakDays == 2) {
        message = '⚠️ You\'ve missed $medicationName for $streakDays days in a row. Please start taking it again.';
      } else if (streakDays >= 7) {
        message = '🚨 Critical: You\'ve missed $medicationName for $streakDays days! This could affect your health. Please consult your doctor.';
      } else {
        message = '⚠️ You\'ve missed $medicationName for $streakDays consecutive days. Try to get back on track.';
      }

      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: 'Medication Adherence Warning',
        body: message,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_warnings',
            'Adherence Warnings',
            channelDescription: 'Warnings for missed dose streaks',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            color: streakDays >= 7 ? const Color(0xFFDC2626) : const Color(0xFFF59E0B), // Red or Amber
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      // Store notification in Firestore
      final notification = MedicationNotificationModel(
        id: const Uuid().v4(),
        uid: uid,
        medicationName: medicationName,
        type: NotificationType.streakWarning,
        title: 'Medication Adherence Warning',
        message: message,
        scheduledTime: DateTime.now(),
        isSent: true,
        sentTime: DateTime.now(),
        missedStreak: streakDays,
        createdAt: DateTime.now(),
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      print('Error notifying streak warning: $e');
    }
  }

  // ==================== ADHERENCE REPORTS ====================

  /// Send daily adherence report
  Future<void> sendDailyAdherenceReport(
    String uid,
    double adherenceScore,
    int totalDoses,
    int takenDoses,
    int missedDoses,
  ) async {
    try {
      final notificationId = 'daily_report_${DateTime.now().day}'.hashCode;
      final adherenceStatus = _getAdherenceStatus(adherenceScore);
      final message = 'Adherence: $adherenceScore% | Today: $takenDoses/$totalDoses doses taken';

      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: 'Daily Adherence Report',
        body: message,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'adherence_reports',
            'Adherence Reports',
            channelDescription: 'Daily medication adherence reports',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
      );

      // Store notification in Firestore
      final notification = MedicationNotificationModel(
        id: const Uuid().v4(),
        uid: uid,
        type: NotificationType.adherenceReport,
        title: 'Daily Adherence Report - $adherenceStatus',
        message: message,
        scheduledTime: DateTime.now(),
        isSent: true,
        sentTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      print('Error sending adherence report: $e');
    }
  }

  // ==================== NOTIFICATION HISTORY ====================

  /// Save notification to Firestore
  Future<void> _saveNotification(
    String uid,
    MedicationNotificationModel notification,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_notificationsCollection)
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  /// Get all notifications for a user
  Future<List<MedicationNotificationModel>> getNotifications(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_notificationsCollection)
          .orderBy('scheduledTime', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => MedicationNotificationModel.fromMap(doc.data()))
          .whereType<MedicationNotificationModel>()
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Get unread notifications
  Future<List<MedicationNotificationModel>> getUnreadNotifications(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_notificationsCollection)
          .where('isRead', isEqualTo: false)
          .orderBy('scheduledTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicationNotificationModel.fromMap(doc.data()))
          .whereType<MedicationNotificationModel>()
          .toList();
    } catch (e) {
      print('Error getting unread notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String uid, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({
            'isRead': true,
            'readTime': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_notificationsCollection)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readTime': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String uid, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getAdherenceStatus(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Poor';
  }

  // ==================== NOTIFICATION RESPONSE HANDLERS ====================

  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    if (notificationResponse.actionId == 'mark_taken') {
      // Handle mark as taken action
      // Extract dose ID from payload and mark as taken
    }
  }
}
