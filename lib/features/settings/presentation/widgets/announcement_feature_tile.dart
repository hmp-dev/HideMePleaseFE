import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class AnnouncementFeatureTile extends StatelessWidget {
  const AnnouncementFeatureTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.onTap,
  });

  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: fontCompactMd(),
                ),
                const VerticalSpace(3),
                Text(
                  subTitle,
                  style: fontCompactXs(color: fore3),
                ),
              ],
            ),

            DefaultImage(
              path: "assets/icons/ic_angle_arrow_right.svg",
              width: 24,
              height: 24,
              color: fore4,
            )
           
          ],
        ),
      ),
    );
  }
}
