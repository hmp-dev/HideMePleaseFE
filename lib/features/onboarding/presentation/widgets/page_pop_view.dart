import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class PagePopup extends StatelessWidget {
  final PageViewData onBoardingSlideData;

  const PagePopup({super.key, required this.onBoardingSlideData});

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
                child: SizedBox(
                  width: 182,
                  height: 158,
                  child: Lottie.asset(onBoardingSlideData.animationPath,
                      fit: BoxFit.contain, alignment: Alignment.center),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const VerticalSpace(10),
              Text(
                onBoardingSlideData.titleTextA,
                textAlign: TextAlign.center,
                style: fontTitle03Bold(),
              ),
              Text(
                onBoardingSlideData.titleTextB,
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
              onBoardingSlideData.descText,
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
  final String animationPath;

  PageViewData({
    required this.titleTextA,
    required this.titleTextB,
    required this.descText,
    required this.animationPath,
  });
}
