import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitUsedText extends StatelessWidget {
  const BenefitUsedText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomImageView(
          svgPath: "assets/icons/ic_check_tik.svg",
          width: 12,
          height: 12,
          color: fore3,
        ),
        const HorizontalSpace(5),
        Text(
          LocaleKeys.used.tr(),
          style: fontCompactSm(color: fore3),
        ),
      ],
    );
  }
}
