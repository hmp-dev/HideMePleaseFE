import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

/// Widget for displaying feature tile.
///
/// This widget is used to show the feature tile with
/// the title and arrow icon. When the user taps on this
/// widget, the provided [onTap] callback is called.
class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.title,
    required this.onTap,
    this.isShowArrowIcon = true,
  });

  /// The title of the feature tile.
  final String title;

  /// The callback function that is called when the widget is tapped.
  /// Changed from VoidCallback to Function() to support both sync and async callbacks
  final Function() onTap;

  /// Whether to show the arrow icon or not.
  final bool isShowArrowIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,  // Ensure entire area is tappable
      onTap: onTap,  // Pass callback directly to avoid closure issues
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: fontCompactMd(),
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
