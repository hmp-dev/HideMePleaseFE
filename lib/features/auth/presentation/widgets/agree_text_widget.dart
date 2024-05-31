import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class AgreeTextWidget extends StatelessWidget {
  const AgreeTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            WebViewScreen.push(
              context: context,
              title: LocaleKeys.termOfServices.tr(),
              url: "https://hidemeplease.xyz/",
            );
          },
          child: Text(
            LocaleKeys.termOfServices.tr(),
            textAlign: TextAlign.center,
            style: fontCompactXsUnderline(color: fore3),
          ),
        ),
        const HorizontalSpace(10),
        GestureDetector(
          onTap: () {
            WebViewScreen.push(
              context: context,
              title: LocaleKeys.privacyPolicy.tr(),
              url: "https://hidemeplease.xyz/",
            );
          },
          child: Text(
            LocaleKeys.privacyPolicy.tr(),
            textAlign: TextAlign.center,
            style: fontCompactXsUnderline(color: fore3),
          ),
        ),
      ],
    );
  }
}
