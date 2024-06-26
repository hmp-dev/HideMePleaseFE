import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class ServeErrorPage extends StatelessWidget {
  const ServeErrorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: DefaultImage(
                  path: "assets/icons/eyes-icon.svg",
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              LocaleKeys.serviceUpdating.tr(),
              style: fontTitle02Bold(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,
              child: Text(
                LocaleKeys.serviceUpdatingMessage.tr(),
                textAlign: TextAlign.center,
                style: fontBodyMd(color: fore2),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,
              child: HMPCustomButton(
                text: LocaleKeys.retryButtonTitle.tr(),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.startUpScreen,
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
