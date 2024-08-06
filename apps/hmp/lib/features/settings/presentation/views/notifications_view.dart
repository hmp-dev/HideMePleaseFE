import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/settings/presentation/widgets/empty_alarms_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/notification_item_widget.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/settings/domain/entities/notification_entity.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.alarm.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (widget.notifications.isEmpty)
                    ? const EmptyAlarmsWidget()
                    : Expanded(
                        child: ListView.builder(
                          itemCount: widget.notifications.length,
                          itemBuilder: (context, index) {
                            return NotificationItemWidget(
                              notification: widget.notifications[index],
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
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
