import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// The `EmptyAlarmsWidget` is a stateless widget that displays an empty state UI
/// when there are no alarms.
///
/// It consists of a sized box that takes up 30% of the height and the full width
/// of the screen. Inside the sized box, there is a column that is aligned to the
/// bottom. The column contains an image and a text widget.
class EmptyAlarmsWidget extends StatelessWidget {
  const EmptyAlarmsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Sized box takes up 30% of the height and full width of the screen.
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width,
      child: Column(
        // Column is aligned to the bottom.
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Custom image view displays the "hmp_eyes_up.svg" image.
          CustomImageView(
            svgPath: "assets/images/hmp_eyes_up.svg",
            width: 60,
            height: 60,
          ),
          // Text displays the localized message for "thereIsNoAlarm"
          Text(
            LocaleKeys.thereIsNoAlarm.tr(),
            style: fontCompactMd(),
          ),
        ],
      ),
    );
  }
}
