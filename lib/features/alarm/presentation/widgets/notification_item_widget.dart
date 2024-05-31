import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/alarm/presentation/screens/alarms_screen.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageView(
                svgPath: notification.icon,
                width: 16,
                height: 16,
              ),
              Text(
                notification.type,
                style: fontCompactXs(),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              notification.title,
              style: fontCompactSm(),
            ),
          ),
          Text(
            notification.time,
            style: fontCompactXs(color: fore3),
          ),
        ],
      ),
    );
  }
}
