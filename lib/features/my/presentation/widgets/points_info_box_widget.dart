import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/large_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class PointsInfoBoxWidget extends StatelessWidget {
  const PointsInfoBoxWidget({
    super.key,
    required this.subTitle,
    required this.title,
    required this.buttonTitle,
    required this.onPressed,
  });

  final String subTitle;
  final String title;
  final String buttonTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgNega5,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subTitle,
            style: fontCompactSmMedium(color: fore2),
          ),
          const VerticalSpace(10),
          Text(
            title,
            style: fontCompactSmMedium(),
          ),
          const VerticalSpace(20),
          LargeButton(
            bgColor: bk1,
            text: buttonTitle,
            onPressed: onPressed,
          ),
          const VerticalSpace(0)
        ],
      ),
    );
  }
}
