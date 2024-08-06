import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

/// Widget for displaying announcement feature tile.
///
/// This widget is used to show the announcement feature tile with
/// the title, created date, and arrow icon. When the user taps on this
/// widget, the provided [onTap] callback is called.
class AnnouncementFeatureTile extends StatelessWidget {
  const AnnouncementFeatureTile({
    super.key,
    required this.title,
    required this.createdAt,
    required this.onTap,
  });

  /// The title of the announcement.
  final String title;

  /// The date when the announcement was created.
  final String createdAt;

  /// Callback function called when the widget is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // GestureDetector is used to detect tap gestures.
    return GestureDetector(
      // When the widget is tapped, the onTap callback is called.
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
                // Display the title of the announcement.
                Text(
                  title,
                  style: fontCompactMd(),
                ),
                const VerticalSpace(3),
                // Display the created date of the announcement.
                Text(
                  getCreatedAt(createdAt),
                  style: fontCompactXs(color: fore3),
                ),
              ],
            ),
            // Display the arrow icon to indicate the tap action.
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
