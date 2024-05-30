import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class LoadMoreIconButton extends StatelessWidget {
  const LoadMoreIconButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.seeMore.tr(),
            style: fontCompactSm(color: fore2),
          ),
          CustomImageView(
            svgPath: 'assets/icons/ic_angle_arrow_down.svg',
            color: fore2,
            width: 16,
          )
        ],
      ),
    );
  }
}
