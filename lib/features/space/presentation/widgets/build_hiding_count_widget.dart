import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

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
          Text(
            "$hidingCount 명 숨어있어요",
            style: fontCompactSm(color: fore2),
          ),
        ],
      ),
    );
  }
}
