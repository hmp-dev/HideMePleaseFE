part of 'notifications_cubit.dart';

class NotificationsState extends BaseState {
  final List<NotificationEntity> notifications;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const NotificationsState({
    required this.notifications,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
  });

  factory NotificationsState.initial() => const NotificationsState(
        notifications: [],
        submitStatus: RequestStatus.initial,
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        notifications,
        submitStatus,
        errorMessage,
      ];

  @override
  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    String? errorMessage,
    RequestStatus? submitStatus,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
      submitStatus: submitStatus ?? this.submitStatus,
    );
  }
}
