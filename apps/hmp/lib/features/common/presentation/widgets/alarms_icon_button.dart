// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/announcement_screen.dart';

class AlarmsIconButton extends StatelessWidget {
  const AlarmsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        getIt<SettingsCubit>().onGetAnnouncements();
        AnnouncementScreen.push(context);

        // final googleAccessToken =
        //     await getIt<AuthLocalDataSource>().getGoogleAccessToken() ?? '';

        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => WepinSDKDemoScreen(
        //             googleAuthAccessToken: googleAccessToken)));
      },
      child: DefaultImage(
        path: "assets/icons/ic_notification.svg",
        width: 32,
        height: 32,
      ),
    );
  }
}
