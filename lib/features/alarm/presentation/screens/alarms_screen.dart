import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/alarm/presentation/widgets/empty_alarms_widget.dart';
import 'package:mobile/features/alarm/presentation/widgets/notification_item_widget.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AlarmsScreen(),
      ),
    );
  }

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (notifications.isEmpty)
                  ? const EmptyAlarmsWidget()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return NotificationItemWidget(
                            notification: notifications[index],
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// temporary Data

class NotificationModel {
  final String type;
  final String title;
  final String time;
  final String icon;

  NotificationModel({
    required this.type,
    required this.title,
    required this.time,
    required this.icon,
  });
}

List<NotificationModel> notifications = [
  NotificationModel(
    type: "알림",
    title: "커뮤니티\nBored Ape Yacht Club이 2등 커뮤니티가 되었습니다.",
    time: "20분 전",
    icon: "assets/icons/ic_user.svg",
  ),
  NotificationModel(
    type: "혜택",
    title: "홍제역 카페 ‘하이드미플리즈', 이수 한식주점 ‘위안'이 하미플 생태계에 온보딩 되었습니다.",
    time: "1시간 전",
    icon: "assets/icons/ic_space_enabled.svg",
  ),
  NotificationModel(
    type: "혜택",
    title: "홍제역 카페 ‘하이드미플리즈', 이수 한식주점 ‘위안'이 하미플 생태계에 온보딩 되었습니다.",
    time: "3시간 전",
    icon: "assets/icons/ic_space_enabled.svg",
  ),
  NotificationModel(
    type: "이벤트",
    title: "오늘 ‘오드하우스'에서 W3W 이벤트를 진행합니다.",
    time: "5시간 전",
    icon: "assets/icons/ic_events_enabled.svg",
  ),
];
