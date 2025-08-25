import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BuildHidingCountWidget extends StatelessWidget {
  const BuildHidingCountWidget({
    super.key,
    required this.hidingCount,
  });

  final int hidingCount;

  @override
  Widget build(BuildContext context) {
    // Positioned 위젯으로 스택 내의 위치를 지정합니다.
    return Positioned(
      // 위치를 왼쪽으로 변경하고, 왼쪽에서 20만큼 마진을 줍니다.
      left: 20,
      bottom: 20,
      child: Container(
        // 패딩을 상:6, 하:6, 좌:10, 우:10 으로 설정합니다.
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          // 배경색을 검은색(0x000000)으로, 투명도를 70%로 설정합니다.
          color: Colors.black.withOpacity(0.7),
          // 모서리 반경을 20으로 설정합니다.
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultImage(
              path: "assets/icons/eyes-icon.svg",
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 5),
            // 기존 ShadowText 대신 일반 Text를 사용하여 배경과 잘 어울리게 합니다.
            Text(
              "$hidingCount ${LocaleKeys.peopleAreHiding.tr()}",
              style: fontCompactSm(color: white),
            )
          ],
        ),
      ),
    );
  }
}