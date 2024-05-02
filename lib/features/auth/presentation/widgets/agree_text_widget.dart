import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';

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
              title: "서비스 이용약관",
              url: "https://hidemeplease.xyz/",
            );
          },
          child: Text(
            "서비스 이용약관",
            textAlign: TextAlign.center,
            style: fontCompactXsUnderline(color: fore3),
          ),
        ),
        const HorizontalSpace(10),
        GestureDetector(
          onTap: () {
            WebViewScreen.push(
              context: context,
              title: "개인정보 취급방침",
              url: "https://hidemeplease.xyz/",
            );
          },
          child: Text(
            "개인정보 취급방침",
            textAlign: TextAlign.center,
            style: fontCompactXsUnderline(color: fore3),
          ),
        ),
      ],
    );
  }
}
