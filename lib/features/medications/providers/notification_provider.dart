import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../services/notification_service.dart';
import '../models/medication_notification_model.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider((ref) => NotificationService.instance);

/// Provider to get all notifications
final notificationsProvider = FutureProvider.autoDispose<List<MedicationNotificationModel>>((ref) async {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(uid);
});

/// Provider to get unread notifications only
final unreadNotificationsProvider = FutureProvider.autoDispose<List<MedicationNotificationModel>>((ref) async {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadNotifications(uid);
});

/// Count of unread notifications
final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final notifications = await ref.watch(unreadNotificationsProvider.future);
  return notifications.length;
});

// ==================== STATE MANAGEMENT ====================

/// State class for notification actions
class NotificationActionState {
  final bool isLoading;
  final String? error;
  final bool success;

  const NotificationActionState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  NotificationActionState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return NotificationActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

/// Notifier for notification actions
class NotificationActionNotifier extends Notifier<NotificationActionState> {
  NotificationService get _service => ref.read(notificationServiceProvider);
  String get _uid {
    final uid = ref.read(authStateProvider).asData?.value?.uid;
    if (uid == null) {
      throw StateError('Not authenticated');
    }
    return uid;
  }

  @override
  NotificationActionState build() {
    return const NotificationActionState();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _service.markNotificationAsRead(_uid, notificationId);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _service.markAllNotificationsAsRead(_uid);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _service.deleteNotification(_uid, notificationId);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  /// Reset action state
  void reset() {
    state = const NotificationActionState();
  }
}

/// Provider for notification action state
final notificationActionProvider = NotifierProvider.autoDispose<NotificationActionNotifier, NotificationActionState>(NotificationActionNotifier.new);
