import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SirenPostSuccessDialog extends StatelessWidget {
  final int pointsUsed;
  final int remainingPoints;

  const SirenPostSuccessDialog({
    Key? key,
    required this.pointsUsed,
    required this.remainingPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFE8F7FF),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF132E41),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/ico_siren_info.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.siren_post_success_title.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 메시지
            Text(
              LocaleKeys.siren_post_success_message.tr(),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF132E41),
                fontFamily: 'LINESeedKR',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 구분선
            Container(
              height: 1,
              color: const Color(0xFF132E41).withOpacity(0.2),
            ),
            const SizedBox(height: 24),

            // SAV 사용 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.siren_sav_used.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6B00),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$pointsUsed',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B00),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SAV 현황 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.siren_sav_balance.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$remainingPoints',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 확인 버튼
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A3FF),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    LocaleKeys.confirm.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'LINESeedKR',
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
