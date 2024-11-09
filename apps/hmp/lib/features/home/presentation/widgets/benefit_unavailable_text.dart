import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitUnavailableText extends StatelessWidget {
  const BenefitUnavailableText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(left: 2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: fore3,
          ),
        ),
        const HorizontalSpace(5),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Text(
            LocaleKeys.unavailable.tr(),
            textAlign: TextAlign.center,
            style: fontCompactSm(color: fore3),
          ),
        ),
      ],
    );
  }
}
