import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:mobile/features/settings/presentation/screens/terms_of_services_screen.dart';
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
            TermsOfServicesScreen.push(context);
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
            PrivacyPolicyScreen.push(context);
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
