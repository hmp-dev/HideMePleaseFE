import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class CommunityErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const CommunityErrorView(
      {super.key, this.message = '데이터를 불러오지 못하였습니다.', required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 183,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(message, style: fontTitle07(color: fore3)),
          const SizedBox(height: 16.0),
          SizedBox(
            width: 200.0,
            child: HMPCustomButton(
              bgColor: backgroundGr1,
              text: LocaleKeys.reload.tr(), //'다시 불러오기',
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
