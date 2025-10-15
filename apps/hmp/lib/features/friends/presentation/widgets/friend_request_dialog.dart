import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class FriendRequestDialog extends StatelessWidget {
  final String nickName;
  final String profileImageUrl;
  final String introduction;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isAcceptMode; // true: 수락, false: 신청

  const FriendRequestDialog({
    super.key,
    required this.nickName,
    required this.profileImageUrl,
    required this.introduction,
    required this.onCancel,
    required this.onConfirm,
    required this.isAcceptMode,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String nickName,
    required String profileImageUrl,
    required String introduction,
    required bool isAcceptMode,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return FriendRequestDialog(
          nickName: nickName,
          profileImageUrl: profileImageUrl,
          introduction: introduction,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
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

            // 사용자 프로필
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF132E41).withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  // 프로필 이미지
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF132E41), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: profileImageUrl.isNotEmpty
                          ? Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/profile_img.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/profile_img.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 닉네임 및 소개
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (introduction.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            introduction,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 안내 메시지
            Text(
              LocaleKeys.friend_request_confirm_message.tr(),
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // 버튼들
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        border: Border.all(color: const Color(0xFF132E41), width: 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          LocaleKeys.cancel.tr(),
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // SAVORY 사용 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
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
                          isAcceptMode
                            ? LocaleKeys.friend_accept_button.tr()  // "이렇게 할게!"
                            : '${LocaleKeys.savory_usage.tr()} 5',  // "SAV 사용 5"
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
