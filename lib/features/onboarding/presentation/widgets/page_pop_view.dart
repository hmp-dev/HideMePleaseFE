import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class PagePopup extends StatelessWidget {
  final PageViewData imageData;

  const PagePopup({super.key, required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          flex: 1,
          child: Text(
            imageData.titleText,
            textAlign: TextAlign.center,
            style: fontSB(18, color: brownishGray),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              imageData.subText,
              textAlign: TextAlign.center,
              style: fontSB(20, color: pureBlack),
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 120,
              child: AspectRatio(
                aspectRatio: 1,
                child: DefaultImage(
                  path: imageData.imagePath,
                  boxFit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
      ],
    );
  }
}

class PageViewData {
  final String titleText;
  final String subText;
  final String imagePath;

  PageViewData({
    required this.titleText,
    required this.subText,
    required this.imagePath,
  });
}
