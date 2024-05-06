import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class FeatureIconWidget extends StatelessWidget {
  const FeatureIconWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  final String title;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: bg3,
            ),
            child: Center(
              child: CustomImageView(
                svgPath: imagePath,
                width: 32,
              ),
            ),
          ),
          const VerticalSpace(7),
          Text(
            title,
            style: fontCompactSmMedium(),
          )
        ],
      ),
    );
  }
}
