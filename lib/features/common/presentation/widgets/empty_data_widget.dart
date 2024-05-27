import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomImageView(
            svgPath: "assets/images/hmp_eyes_up.svg",
            width: 60,
            height: 60,
          ),
          Text(
            LocaleKeys.noDataAvailable.tr(),
            style: fontCompactMd(),
          ),
        ],
      ),
    );
  }
}
