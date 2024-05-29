import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class CategoryIconWidget extends StatelessWidget {
  const CategoryIconWidget({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final bool isSelected;
  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                color: bgNega5,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: DefaultImage(
                  path: icon,
                  width: 32,
                  height: 32,
                  color: isSelected ? Colors.white : fore3,
                ),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: isSelected
                  ? fontCompactSmBold()
                  : fontCompactSm(color: fore3),
            ),
          ],
        ),
      ),
    );
  }
}
