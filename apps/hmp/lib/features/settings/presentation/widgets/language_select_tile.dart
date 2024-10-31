import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

/// Widget for displaying announcement feature tile.
///
/// This widget is used to show the announcement feature tile with
/// the title, created date, and arrow icon. When the user taps on this
/// widget, the provided [onTap] callback is called.
class LanguageSelectTile extends StatelessWidget {
  const LanguageSelectTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  /// The title of the announcement.
  final String title;

  /// Callback function called when the widget is tapped.
  final VoidCallback onTap;

  final bool isSelected;

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
            Text(
              title,
              style: fontCompactMd(),
            ),
            (isSelected)
                ? DefaultImage(
                    path: "assets/icons/blue_tick.svg",
                    width: 24,
                    height: 24,
                  )
                : const SizedBox(
                    width: 24,
                    height: 24,
                  )
          ],
        ),
      ),
    );
  }
}
