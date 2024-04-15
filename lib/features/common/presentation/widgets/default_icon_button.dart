import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class DefaultIconButton extends StatelessWidget {
  const DefaultIconButton({
    super.key,
    required this.iconPath,
    required this.onTap,
  });

  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DefaultImage(path: iconPath),
    );
  }
}
