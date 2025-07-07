import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitAvailableText extends StatelessWidget {
  const BenefitAvailableText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: hmpBlue, // 블루 아이덴티티 색상
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            LocaleKeys.available.tr(),
            style: fontCompactSm().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
