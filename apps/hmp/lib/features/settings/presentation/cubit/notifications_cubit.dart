import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/settings/domain/entities/notification_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'notifications_state.dart';

@lazySingleton
class NotificationsCubit extends BaseCubit<NotificationsState> {
  final SettingsRepository _settingsRepository;

  // Injects the SettingsRepository to the NotificationsCubit
  NotificationsCubit(
    this._settingsRepository,
  ) : super(NotificationsState.initial());

  /// Retrieves the notifications from the server using the
  /// SettingsRepository and emits the states accordingly.
  ///
  /// The cubit starts by emitting the loading state. If the repository
  /// returns a failure, the cubit emits the failure state with the
  /// 'somethingError' translated message. If the repository returns a success,
  /// the cubit emits the success state with the notifications mapped to
  /// NotificationEntity objects.
  ///
  /// [updateUnreadCount] - Whether to fetch unread count after loading notifications.
  /// Defaults to true. Set to false when entering notification screen to preserve cleared badge.
  Future<void> onStart({bool updateUnreadCount = true}) async {
    // Emits the loading state
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    // Retrieves the notifications from the repository
    final response = await _settingsRepository.getNotifications();

    // Handles the response based on the result
    response.fold(
      // If the response is a failure, emits the failure state
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // If the response is a success, maps the result to NotificationEntity
      // objects and emits the success state
      (result) {
        final resultList = result
            .map((e) => e.toEntity())
            .where((notification) {
              final typeLower = notification.type.toLowerCase();
              // 체크인/체크아웃 알림 필터링 제외
              return !(typeLower.contains("checkin") ||
                       typeLower.contains("check_in") ||
                       typeLower.contains("checkout") ||
                       typeLower.contains("check_out"));
            })
            .toList();
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            notifications: resultList,
          ),
        );

        // Also fetch unread count (only if updateUnreadCount is true)
        if (updateUnreadCount) {
          getUnreadCount();
        }
      },
    );
  }

  /// Retrieves the count of unread notifications.
  Future<void> getUnreadCount() async {
    print('🔔 [NotificationsCubit] getUnreadCount() called - current count: ${state.unreadCount}');
    print('🔔 [NotificationsCubit] Stack trace:\n${StackTrace.current}');

    final response = await _settingsRepository.getUnreadNotificationsCount();

    response.fold(
      (err) {
        print('🔔 [NotificationsCubit] getUnreadCount() failed: ${err.message}');
      },
      (count) {
        print('🔔 [NotificationsCubit] getUnreadCount() received from API: $count');
        print('🔔 [NotificationsCubit] getUnreadCount() emitting new count: $count');
        emit(state.copyWith(unreadCount: count));
        print('🔔 [NotificationsCubit] getUnreadCount() emit completed - current count: ${state.unreadCount}');
      },
    );
  }

  /// Clears the badge immediately (UI only).
  /// Used when user enters the notification screen.
  void clearBadge() {
    print('🔔 [NotificationsCubit] clearBadge() called - current count: ${state.unreadCount}');
    emit(state.copyWith(unreadCount: 0));
    print('🔔 [NotificationsCubit] clearBadge() after emit - new count: ${state.unreadCount}');
  }

  /// Marks a notification as read using optimistic update.
  ///
  /// Immediately updates the UI, then calls the API.
  /// If the API call fails, reverts the change.
  Future<void> markAsRead(String notificationId) async {
    // Find the notification
    final notificationIndex = state.notifications.indexWhere(
      (n) => n.id == notificationId,
    );

    if (notificationIndex == -1) return;

    final notification = state.notifications[notificationIndex];

    // If already read, do nothing
    if (notification.isRead) return;

    // Optimistic update: mark as read immediately
    final updatedNotifications = List<NotificationEntity>.from(state.notifications);
    updatedNotifications[notificationIndex] = notification.copyWith(isRead: true);

    final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;

    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    ));

    // Call the API
    final response = await _settingsRepository.markNotificationAsRead(notificationId);

    response.fold(
      (err) {
        // Revert on failure
        final revertedNotifications = List<NotificationEntity>.from(state.notifications);
        revertedNotifications[notificationIndex] = notification;

        emit(state.copyWith(
          notifications: revertedNotifications,
          unreadCount: state.unreadCount + 1,
        ));
      },
      (success) {
        // Success - the optimistic update is already applied
      },
    );
  }

  /// Marks all unread notifications as read.
  ///
  /// Uses optimistic update to immediately set unread count to 0,
  /// then calls the batch API to mark all as read.
  Future<void> markAllAsRead() async {
    print('🔔 [NotificationsCubit] markAllAsRead() called - current count: ${state.unreadCount}');

    // Get all unread notifications
    final unreadNotifications = state.notifications
        .where((notification) => !notification.isRead)
        .toList();

    print('🔔 [NotificationsCubit] markAllAsRead() found ${unreadNotifications.length} unread notifications');

    // If no unread notifications, do nothing
    if (unreadNotifications.isEmpty) {
      print('🔔 [NotificationsCubit] markAllAsRead() - no unread notifications, returning');
      return;
    }

    // Optimistic update: mark all as read immediately
    final updatedNotifications = state.notifications.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();

    print('🔔 [NotificationsCubit] markAllAsRead() - emitting unreadCount: 0');
    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    ));
    print('🔔 [NotificationsCubit] markAllAsRead() - emit completed, current count: ${state.unreadCount}');

    // Call the batch API to mark all notifications as read
    print('🔔 [NotificationsCubit] markAllAsRead() - calling API');
    final response = await _settingsRepository.markAllNotificationsAsRead();

    response.fold(
      (error) {
        // Silently ignore failures - the optimistic update stays
        print('🔔 [NotificationsCubit] markAllAsRead() API failed: ${error.message}');
      },
      (result) {
        print('🔔 [NotificationsCubit] markAllAsRead() API success: ${result.updatedCount} notifications marked as read');
      },
    );
  }

  /// Deletes a notification.
  Future<void> deleteNotification(String notificationId) async {
    final response = await _settingsRepository.deleteNotification(notificationId);

    response.fold(
      (err) {
        emit(state.copyWith(
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (success) {
        // Remove from the list
        final updatedNotifications = state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        emit(state.copyWith(
          notifications: updatedNotifications,
          errorMessage: '',
        ));

        // Refresh unread count
        getUnreadCount();
      },
    );
  }
}
