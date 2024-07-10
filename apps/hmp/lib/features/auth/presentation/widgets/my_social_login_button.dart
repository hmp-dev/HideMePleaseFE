import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class MySocialLoginButton extends StatelessWidget {
  const MySocialLoginButton({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.imgHeightWidth = 36,
  });

  final String imagePath;
  final VoidCallback onTap;
  final double imgHeightWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: DefaultImage(
              path: imagePath,
              width: imgHeightWidth,
              height: imgHeightWidth,
            ),
          ),
        ));
  }
}
