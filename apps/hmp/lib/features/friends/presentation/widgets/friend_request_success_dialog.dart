import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class FriendRequestSuccessDialog extends StatelessWidget {
  final int savoryBalance;
  final VoidCallback onConfirm;
  final bool isAcceptMode; // true: 수락, false: 신청

  const FriendRequestSuccessDialog({
    super.key,
    required this.savoryBalance,
    required this.onConfirm,
    required this.isAcceptMode,
  });

  static Future<void> show(
    BuildContext context, {
    required int savoryBalance,
    required bool isAcceptMode,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FriendRequestSuccessDialog(
          savoryBalance: savoryBalance,
          onConfirm: () => Navigator.of(context).pop(),
          isAcceptMode: isAcceptMode,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: (screenWidth - dialogWidth) / 2),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF8FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF000000), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/ico_noti_friend.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isAcceptMode
                    ? LocaleKeys.friend_accept_title.tr()  // "프렌즈 수락"
                    : LocaleKeys.friend_request_confirm_title.tr(),  // "프렌즈 신청"
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 안내 메시지
            Text(
              isAcceptMode
                ? LocaleKeys.friend_accept_success_message.tr()  // "서로 프렌즈가 되면..."
                : LocaleKeys.friend_request_success_message.tr(),  // "상대방이 프렌즈 신청을..."
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // SAVORY 정보
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF132E41).withOpacity(0.2), width: 1),
              ),
              child: Column(
                children: [
                  // SAVORY 획득
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${LocaleKeys.savory_usage.tr()}',
                        style: const TextStyle(
                          color: Color(0xFFEA5211),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ico_sav_red.svg',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '5',
                            style: TextStyle(
                              color: Color(0xFFEA5211),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // SAVORY 현황
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${LocaleKeys.savory_balance.tr()}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ico_sav_gray.svg',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$savoryBalance',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 확인 버튼
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff00A3FF),
                      const Color(0xff5FC5FF),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFF000000), width: 1),
                ),
                child: Center(
                  child: Text(
                    LocaleKeys.got_it_button.tr(),
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
