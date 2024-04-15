import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';

class AgreeTextWidget extends StatelessWidget {
  const AgreeTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            WebViewScreen.push(
              context: context,
              title: "서비스 이용약관",
              url: "https://hidemeplease.xyz/",
            );
          },
          child: Text(
            "서비스 이용약관",
            textAlign: TextAlign.center,
            style: fontRUnderLined(14),
          ),
        ),
        Text(
          "및 ",
          textAlign: TextAlign.center,
          style: fontR(14, color: white),
        ),
        GestureDetector(
          onTap: () {
            WebViewScreen.push(
              context: context,
              title: "개인정보 처리방침",
              url: "https://hidemeplease.xyz/",
            );
          },
          child: Text(
            "개인정보 처리방침",
            textAlign: TextAlign.center,
            style: fontRUnderLined(14),
          ),
        ),
        Text(
          "에 동의합니다.",
          textAlign: TextAlign.center,
          style: fontR(14, color: white),
        ),
      ],
    );
  }
}
