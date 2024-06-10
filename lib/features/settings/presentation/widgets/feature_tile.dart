import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.title,
    required this.onTap,
    this.isShowArrowIcon = true,
  });

  final String title;
  final VoidCallback onTap;
  final bool isShowArrowIcon;

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
            Text(
              title,
              style: fontCompactSmMedium(),
            ),
            if (isShowArrowIcon)
              DefaultImage(
                path: "assets/icons/ic_angle_arrow_right.svg",
                width: 24,
                height: 24,
                color: fore4,
              ),
          ],
        ),
      ),
    );
  }
}
