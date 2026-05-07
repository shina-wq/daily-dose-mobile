import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart' show Color;
import '../core/navigation/app_router.dart';
import '../features/medications/models/medication_notification_model.dart';
import '../features/medications/models/medication_dose_model.dart';

abstract class LocalNotificationClient {
  Future<void> initialize({
    required InitializationSettings settings,
    required void Function(NotificationResponse response) onDidReceiveNotificationResponse,
  });

  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails();

  Future<void> zonedSchedule({
    required int id,
    required String? title,
    required String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
  });

  Future<void> show({
    required int id,
    required String? title,
    required String? body,
    required NotificationDetails notificationDetails,
    String? payload,
  });

  Future<void> cancel(int id);

  Future<IOSFlutterLocalNotificationsPlugin?> resolveIosImplementation();
}

class FlutterLocalNotificationClient implements LocalNotificationClient {
  FlutterLocalNotificationClient() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize({
    required InitializationSettings settings,
    required void Function(NotificationResponse response) onDidReceiveNotificationResponse,
  }) {
    return _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String? title,
    required String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
    );
  }

  @override
  Future<void> show({
    required int id,
    required String? title,
    required String? body,
    required NotificationDetails notificationDetails,
    String? payload,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int id) {
    return _plugin.cancel(id: id);
  }

  @override
  Future<IOSFlutterLocalNotificationsPlugin?> resolveIosImplementation() {
    return Future.value(
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>(),
    );
  }
}

class NotificationService {
  NotificationService._({
    LocalNotificationClient? client,
    FirebaseFirestore? firestore,
    DateTime Function()? now,
  })  : _client = client ?? FlutterLocalNotificationClient(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _now = now ?? DateTime.now;

  static final NotificationService instance = NotificationService._();

  factory NotificationService.forTesting({
    LocalNotificationClient? client,
    FirebaseFirestore? firestore,
    DateTime Function()? now,
  }) {
    return NotificationService._(
      client: client,
      firestore: firestore,
      now: now,
    );
  }

  final LocalNotificationClient _client;
  final FirebaseFirestore _firestore;
  final DateTime Function() _now;
  static const String _notificationsCollection = 'medication_notifications';

  bool _isInitialized = false;
  String? _pendingNotificationRoute;
  void Function(String route)? onNotificationTapped;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

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

    await _client.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    final launchDetails = await _client.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _pendingNotificationRoute = resolveNotificationRoute(
        launchDetails?.notificationResponse?.payload,
      );
    }

    // Request iOS permissions
    final iosImplementation = await _client.resolveIosImplementation();
    await iosImplementation?.requestPermissions(
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
      if (notificationTime.isBefore(_now())) {
        return;
      }

      final notificationId = dose.id.hashCode;
      final notificationDocId = _reminderNotificationDocId(dose.id);
      final existingNotification = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_notificationsCollection)
          .doc(notificationDocId)
          .get();

      if (existingNotification.exists) {
        return;
      }

      final message = 'Time to take ${dose.medicationName}';
      final body = 'Dosage: ${dose.dosage}';
      final actionUrl = '/medications/${dose.medicationId}/dose/${dose.id}';

      // Schedule local notification
      await _client.cancel(notificationId);
      await _client.zonedSchedule(
        id: notificationId,
        title: 'Medication Reminder',
        body: '$message - $body',
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
        payload: actionUrl,
      );

      // Store notification in Firestore
      final notification = MedicationNotificationModel(
        id: notificationDocId,
        uid: uid,
        medicationId: dose.medicationId,
        medicationName: dose.medicationName,
        type: NotificationType.reminder,
        title: 'Medication Reminder',
        message: '$message - $body',
        scheduledTime: notificationTime,
        isSent: true,
        sentTime: _now(),
        actionUrl: actionUrl,
        createdAt: _now(),
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      throw Exception('Failed to schedule medication reminder: $e');
    }
  }

  /// Schedule medication reminders for all pending doses
  Future<void> scheduleAllPendingReminders(String uid) async {
    try {
      final now = _now();
      final tomorrow = now.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('medication_doses')
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in snapshot.docs) {
        final dose = MedicationDoseModel.fromMap(doc.data());
        if (dose.scheduledTime.isBefore(now) || dose.scheduledTime.isAfter(tomorrow)) {
          continue;
        }
        await scheduleMedicationReminder(uid, dose);
      }
    } catch (e) {
      throw Exception('Failed to schedule all pending reminders: $e');
    }
  }

  // ==================== MISSED DOSE ALERTS ====================

  /// Send notification for a missed dose
  Future<void> notifyMissedDose(String uid, MedicationDoseModel dose) async {
    try {
      final notificationId = '${dose.id}_missed'.hashCode;
      final message = '${dose.medicationName} was not taken at ${_formatTime(dose.scheduledTime)}';
      final actionUrl = '/medications/${dose.medicationId}/dose/${dose.id}';

      await _client.show(
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
        payload: actionUrl,
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
        scheduledTime: _now(),
        isSent: true,
        sentTime: _now(),
        actionUrl: actionUrl,
        createdAt: _now(),
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      throw Exception('Failed to notify missed dose: $e');
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

      final notificationId = '${medicationName}_streak'.hashCode;
      String message;

      if (streakDays == 2) {
        message = '⚠️ You\'ve missed $medicationName for $streakDays days in a row. Please start taking it again.';
      } else if (streakDays >= 7) {
        message = '🚨 Critical: You\'ve missed $medicationName for $streakDays days! This could affect your health. Please consult your doctor.';
      } else {
        message = '⚠️ You\'ve missed $medicationName for $streakDays consecutive days. Try to get back on track.';
      }

      await _client.show(
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
        scheduledTime: _now(),
        isSent: true,
        sentTime: _now(),
        missedStreak: streakDays,
        createdAt: _now(),
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      throw Exception('Failed to notify streak warning: $e');
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
      final notificationId = 'daily_report_${_now().day}'.hashCode;
      final now = _now();
      final adherenceStatus = _getAdherenceStatus(adherenceScore);
      final message = 'Adherence: $adherenceScore% | Today: $takenDoses/$totalDoses doses taken';

      await _client.show(
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
        scheduledTime: now,
        isSent: true,
        sentTime: now,
        createdAt: now,
      );

      await _saveNotification(uid, notification);
    } catch (e) {
      throw Exception('Failed to send adherence report: $e');
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
      throw Exception('Failed to save notification: $e');
    }
  }

  String? consumePendingNotificationRoute() {
    final route = _pendingNotificationRoute;
    _pendingNotificationRoute = null;
    return route;
  }

  static String resolveNotificationRoute(String? actionUrl) {
    if (actionUrl == null || actionUrl.isEmpty) {
      return AppRouter.notificationsRoute;
    }

    if (actionUrl.startsWith('/medications/')) {
      return AppRouter.medicationsRoute;
    }

    if (actionUrl.startsWith(AppRouter.notificationsRoute)) {
      return AppRouter.notificationsRoute;
    }

    return AppRouter.homeRoute;
  }

  String _reminderNotificationDocId(String doseId) {
    return 'reminder_$doseId';
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
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
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
          .toList();
    } catch (e) {
      throw Exception('Failed to get unread notifications: $e');
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
      throw Exception('Failed to mark notification as read: $e');
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
      throw Exception('Failed to mark all notifications as read: $e');
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
      throw Exception('Failed to delete notification: $e');
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
    final route = resolveNotificationRoute(notificationResponse.payload);

    if (notificationResponse.actionId == 'mark_taken') {
      // Handle mark as taken action
      // Extract dose ID from payload and mark as taken
      return;
    }

    if (onNotificationTapped != null) {
      onNotificationTapped!(route);
      return;
    }

    _pendingNotificationRoute = route;
  }
}