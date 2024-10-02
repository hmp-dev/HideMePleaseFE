// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/announcement_screen.dart';
import 'package:mobile/features/wepin/wepin_sdk_demo_screen.dart';

class AlarmsIconButton extends StatelessWidget {
  const AlarmsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final idToken =
            await getIt<AuthLocalDataSource>().getGoogleAccessToken();
        "the idToken passing to Wepin is $idToken".log();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WepinSDKDemoScreen(googleAuthAccessToken: idToken ?? ""),
            ));

        // getIt<SettingsCubit>().onGetAnnouncements();
        // AnnouncementScreen.push(context);
      },
      child: DefaultImage(
        path: "assets/icons/ic_notification.svg",
        width: 32,
        height: 32,
      ),
    );
  }
}
