import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/settings/domain/entities/notification_entity.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            color: Colors.transparent,
            child: Row(
              children: [
                // Left: Small Icon
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _getIconPath(notification.type),
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.notifications, size: 14);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Middle: Title + Time
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        checkTimeDifference(notification.createdAt),
                        style: TextStyle(
                          color: fore3,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Right: Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFF000000),
                ),
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  String _getIconPath(String type) {
    final typeLower = type.toLowerCase();
    final titleLower = notification.title.toLowerCase();
    final bodyLower = notification.body.toLowerCase();

    // 1단계: 타입 먼저 체크
    // 친구 관련 알림 (친구 신청, 친구 수락)
    if (typeLower.contains("friendrequest") || typeLower.contains("friend_request") ||
        typeLower.contains("friend_accepted") || typeLower.contains("friendaccepted")) {
      return "assets/icons/ico_noti_friend.png";
    }

    // SAV 알림 (획득 및 사용, 체크인, 체크아웃, 베네핏)
    if (typeLower.contains("sav_earn") || typeLower.contains("savearn") ||
        typeLower.contains("sav_usage") || typeLower.contains("savusage") ||
        typeLower.contains("checkin") || typeLower.contains("check_in") ||
        typeLower.contains("checkout") || typeLower.contains("check_out") ||
        typeLower.contains("auto_checkout") ||
        typeLower.contains("benefits")) {
      return "assets/icons/ico_noti_sav.png";
    }

    // 사이렌, 매칭 알림
    if (typeLower.contains("siren") || typeLower.contains("matching")) {
      return "assets/icons/ico_noti_siren.png";
    }

    // 2단계: 타입이 매칭 안되면 제목/본문에서 체크
    // 친구 관련
    if (titleLower.contains("친구") || bodyLower.contains("친구") ||
        titleLower.contains("friend") || bodyLower.contains("friend")) {
      return "assets/icons/ico_noti_friend.png";
    }

    // SAV/체크인 관련
    if (titleLower.contains("sav") || bodyLower.contains("sav") ||
        titleLower.contains("포인트") || bodyLower.contains("포인트") ||
        titleLower.contains("체크인") || bodyLower.contains("체크인") ||
        titleLower.contains("체크아웃") || bodyLower.contains("체크아웃")) {
      return "assets/icons/ico_noti_sav.png";
    }

    // 사이렌/매칭 관련
    if (titleLower.contains("사이렌") || bodyLower.contains("사이렌") ||
        titleLower.contains("siren") || bodyLower.contains("siren") ||
        titleLower.contains("매칭") || bodyLower.contains("매칭") ||
        titleLower.contains("matching") || bodyLower.contains("matching")) {
      return "assets/icons/ico_noti_siren.png";
    }

    // 기본 아이콘
    return "assets/icons/ico_noti_friend.png";
  }
}
