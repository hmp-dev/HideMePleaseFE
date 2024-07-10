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
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(left: 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: hmpBlue,
              ),
            ),
            const HorizontalSpace(5),
            Text(
              LocaleKeys.available.tr(),
              style: fontCompactSm(color: hmpBlue),
            ),
          ],
        ),
      ),
    );
  }
}
