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
          flex: 5,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 120,
              child: AspectRatio(
                aspectRatio: 0.5,
                child: DefaultImage(
                  path: imageData.imagePath,
                  boxFit: BoxFit.contain,
                  width: 182,
                  height: 158,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Text(
                imageData.titleTextA,
                textAlign: TextAlign.center,
                style: fontTitle03Bold(),
              ),
              Text(
                imageData.titleTextB,
                textAlign: TextAlign.center,
                style: fontTitle03Bold(color: hmpBlue),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            width: 250,
            child: Text(
              imageData.descText,
              textAlign: TextAlign.center,
              style: fontCompactMd(color: fore2),
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
  final String titleTextA;
  final String titleTextB;
  final String descText;
  final String imagePath;

  PageViewData({
    required this.titleTextA,
    required this.titleTextB,
    required this.descText,
    required this.imagePath,
  });
}
