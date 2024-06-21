import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/settings/domain/entities/notification_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.notification,
  });

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getTypeWithIcon(notification.type),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              notification.title,
              style: fontCompactSm(),
            ),
          ),
          Text(
            checkTimeDifference(notification.createdAt),
            style: fontCompactXs(color: fore3),
          ),
        ],
      ),
    );
  }

  Widget getTypeWithIcon(String type) {
    Widget widget = const SizedBox();

    if (type.contains("Community")) {
      widget = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomImageView(
            svgPath: "assets/icons/ic_user.svg",
            width: 16,
            height: 16,
          ),
          const HorizontalSpace(5),
          Text(
            LocaleKeys.community.tr(),
            style: fontCompactXs(color: fore2),
          )
        ],
      );
    }

    if (type.contains("Benefits")) {
      widget = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomImageView(
            svgPath: "assets/icons/ic_space_enabled.svg",
            width: 16,
            height: 16,
          ),
          const HorizontalSpace(5),
          Text(
            LocaleKeys.benefits.tr(),
            style: fontCompactXs(color: fore2),
          )
        ],
      );
    }

    if (type.contains("Event")) {
      widget = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomImageView(
            svgPath: "assets/icons/ic_events_enabled.svg",
            width: 16,
            height: 16,
          ),
          const HorizontalSpace(5),
          Text(
            LocaleKeys.event.tr(),
            style: fontCompactXs(color: fore2),
          )
        ],
      );
    }

    return widget;
  }
}
