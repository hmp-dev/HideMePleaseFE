import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class GetFreeNftView extends StatelessWidget {
  final VoidCallback onTap;
  const GetFreeNftView({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                LocaleKeys.evenPeopleWithNftTitle.tr(),
                style: fontTitle05Medium(),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.getAFreeNft.tr(),
                    style: fontCompactSm(color: fore2),
                  ),
                  CustomImageView(
                    svgPath: 'assets/icons/ic_angle_arrow_down.svg',
                    color: fore2,
                    width: 16,
                  )
                ],
              ),
            ),
          ],
        ),
        CustomImageView(
          imagePath: 'assets/images/connect.png',
          width: 88,
          height: 88,
        )
      ],
    );
  }
}
