import 'package:flutter/material.dart';
import 'package:mobile/features/alarm/presentation/screens/alarms_screen.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class AlarmsIconButton extends StatelessWidget {
  const AlarmsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AlarmsScreen.push(context);
      },
      child: DefaultImage(
        path: "assets/icons/ic_notification.svg",
        width: 32,
      ),
    );
  }
}
