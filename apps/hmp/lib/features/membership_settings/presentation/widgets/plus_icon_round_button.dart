import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';

class PlusIconRoundButton extends StatelessWidget {
  const PlusIconRoundButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: bgNega4,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: CustomImageView(
            svgPath: "assets/images/ic_plus.svg",
          ),
        ),
      ),
    );
  }
}
