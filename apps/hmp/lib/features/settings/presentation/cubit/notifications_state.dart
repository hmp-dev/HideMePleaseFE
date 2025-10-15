part of 'notifications_cubit.dart';

class NotificationsState extends BaseState {
  final List<NotificationEntity> notifications;
  final String errorMessage;
  final int unreadCount;

  @override
  final RequestStatus submitStatus;

  const NotificationsState({
    required this.notifications,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    this.unreadCount = 0,
  });

  factory NotificationsState.initial() => const NotificationsState(
        notifications: [],
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        unreadCount: 0,
      );

  @override
  List<Object?> get props => [
        notifications,
        submitStatus,
        errorMessage,
        unreadCount,
      ];

  @override
  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    String? errorMessage,
    RequestStatus? submitStatus,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
      submitStatus: submitStatus ?? this.submitStatus,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
