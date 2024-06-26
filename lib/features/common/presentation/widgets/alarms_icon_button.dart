import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/home/presentation/views/solana_import_wallet_view.dart';
import 'package:mobile/features/settings/presentation/screens/notifications_screen.dart';
import 'package:solana/solana.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

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
