import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/shadow_text.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BuildHidingCountWidget extends StatelessWidget {
  const BuildHidingCountWidget({
    super.key,
    required this.hidingCount,
  });

  final int hidingCount;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Row(
        children: [
          DefaultImage(
            path: "assets/icons/eyes-icon.svg",
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 5),
          ShadowText(
            data: "$hidingCount ${LocaleKeys.peopleAreHiding.tr()}",
            style: fontCompactSm(color: white),
          )
        ],
      ),
    );
  }
}
