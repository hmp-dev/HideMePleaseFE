import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class UpdateAtTimeWidget extends StatelessWidget {
  const UpdateAtTimeWidget({
    super.key,
    required this.updatedAt,
    this.isShowIcon = true,
  });

  final DateTime updatedAt;
  final bool isShowIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "${formatDate(updatedAt)} ${LocaleKeys.as_of.tr()}",
          style: fontCompactSm(color: fore3),
        ),
        if (isShowIcon)
          Row(
            children: [
              const HorizontalSpace(3),
              DefaultImage(
                path: "assets/icons/ic_arrow_clockwise.svg",
                color: white,
                height: 16,
              ),
            ],
          )
      ],
    );
  }
}
