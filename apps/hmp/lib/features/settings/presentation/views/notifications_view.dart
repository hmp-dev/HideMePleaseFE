import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/settings/presentation/widgets/empty_alarms_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/notification_item_widget.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/settings/domain/entities/notification_entity.dart';
import 'package:mobile/features/settings/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/friends/presentation/widgets/friend_request_list_dialog.dart';
import 'package:mobile/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/announcement_screen.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// `NotificationsView` is a stateful widget that represents the screen for managing user notifications.
/// It displays a list of notifications to the user and provides a refresh button to fetch new notifications.
class NotificationsView extends StatefulWidget {
  /// The `onRefresh` function is called when the user pulls down to refresh the list of notifications.
  ///
  /// It returns a [Future] that resolves to `void`.
  final Future<void> Function() onRefresh;

  /// The `notifications` list contains the notifications to be displayed on the screen.
  ///
  /// It is a list of [NotificationEntity] objects.
  final List<NotificationEntity> notifications;

  /// Creates a new instance of the `NotificationsView` class.
  ///
  /// The `onRefresh` and `notifications` parameters are required.
  const NotificationsView({
    super.key,
    required this.onRefresh,
    required this.notifications,
  });

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    // 친구 신청 목록 로드 (요약 카드 표시를 위해)
    getIt<FriendsCubit>().getReceivedFriendRequests();
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // 읽음 처리 (읽지 않은 알림만)
    if (!notification.isRead) {
      getIt<NotificationsCubit>().markAsRead(notification.id);
    }

    // 친구 신청 알림인 경우 친구 신청 목록 다이얼로그 표시
    if (notification.type.contains("FriendRequest") ||
        notification.type.contains("FRIEND_REQUEST")) {
      FriendRequestListDialog.show(context);
    }
    // 다른 알림 타입에 대한 처리 추가 가능
    // TODO: 사이렌, 매칭 등 다른 알림 타입 처리
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/ico_bell.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text(
            LocaleKeys.alarm.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: BlocBuilder<FriendsCubit, FriendsState>(
        bloc: getIt<FriendsCubit>(),
        builder: (context, friendsState) {
          final hasReceivedRequests = friendsState.receivedRequests.isNotEmpty;
          final requestCount = friendsState.receivedRequests.length;

          // 읽지 않은 공지사항이 있는지 확인
          final hasUnreadAnnouncements = widget.notifications.any(
            (notification) =>
                notification.type.toUpperCase().contains('ANNOUNCEMENT') &&
                !notification.isRead,
          );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 친구 신청 요약 카드
                    if (hasReceivedRequests)
                      GestureDetector(
                        onTap: () {
                          FriendRequestListDialog.show(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9F2FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2CB3FF).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/ico_friend_request.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  requestCount == 1
                                      ? LocaleKeys.friend_request_received_single.tr()
                                      : LocaleKeys.friend_request_received_multiple.tr(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 공지사항 요약 카드
                    if (hasUnreadAnnouncements)
                      GestureDetector(
                        onTap: () {
                          AnnouncementScreen.push(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFB800).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/ico_bell.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  LocaleKeys.notification_announcement_message.tr(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 알림 목록
                    (widget.notifications.isEmpty)
                        ? const Expanded(child: EmptyAlarmsWidget())
                        : Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: widget.notifications.length,
                              itemBuilder: (context, index) {
                                final notification = widget.notifications[index];
                                return NotificationItemWidget(
                                  notification: notification,
                                  onTap: () => _handleNotificationTap(notification),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// temporary Data

// class NotificationModel {
//   final String type;
//   final String title;
//   final String time;
//   final String icon;

//   NotificationModel({
//     required this.type,
//     required this.title,
//     required this.time,
//     required this.icon,
//   });
// }

// List<NotificationModel> notifications = [
//   NotificationModel(
//     type: "알림",
//     title: "커뮤니티\nBored Ape Yacht Club이 2등 커뮤니티가 되었습니다.",
//     time: "20분 전",
//     icon: "assets/icons/ic_user.svg",
//   ),
//   NotificationModel(
//     type: "혜택",
//     title: "홍제역 카페 ‘하이드미플리즈', 이수 한식주점 ‘위안'이 하미플 생태계에 온보딩 되었습니다.",
//     time: "1시간 전",
//     icon: "assets/icons/ic_space_enabled.svg",
//   ),
//   NotificationModel(
//     type: "혜택",
//     title: "홍제역 카페 ‘하이드미플리즈', 이수 한식주점 ‘위안'이 하미플 생태계에 온보딩 되었습니다.",
//     time: "3시간 전",
//     icon: "assets/icons/ic_space_enabled.svg",
//   ),
//   NotificationModel(
//     type: "이벤트",
//     title: "오늘 ‘오드하우스'에서 W3W 이벤트를 진행합니다.",
//     time: "5시간 전",
//     icon: "assets/icons/ic_events_enabled.svg",
//   ),
// ];
