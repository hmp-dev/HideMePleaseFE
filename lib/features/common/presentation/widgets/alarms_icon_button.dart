import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/settings/presentation/screens/notifications_screen.dart';

class AlarmsIconButton extends StatelessWidget {
  const AlarmsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NotificationsScreen.push(context);
      },
      child: DefaultImage(
        path: "assets/icons/ic_notification.svg",
        width: 32,
        height: 32,
      ),
    );
  }
}
