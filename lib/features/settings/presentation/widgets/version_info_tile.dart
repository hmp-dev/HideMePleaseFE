import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class VersionInfoTile extends StatelessWidget {
  const VersionInfoTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.versionInfo.tr(),
                style: fontCompactMd(),
              ),
              Text(
                "${LocaleKeys.latestVersion.tr()}: 24.12.0",
                style: fontCompactXs(color: fore3),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "24.12.0(241200)",
            style: fontCompactSmMedium(color: hmpBlue),
          ),
        ],
      ),
    );
  }
}
