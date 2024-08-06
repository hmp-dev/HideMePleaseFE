import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

/// A widget that displays a page of the onboarding process.
///
/// It contains an animation, a title, and a description.
class PagePopup extends StatelessWidget {
  // The data for the page to be displayed.
  final PageViewData onBoardingSlideData;

  // Constructs a PagePopup widget.
  const PagePopup({super.key, required this.onBoardingSlideData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Leave some space at the top.
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        // Display the animation.
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
        // Display the title and subtitle.
        Expanded(
          flex: 3,
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
        // Display the description.
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
        // Leave some space at the bottom.
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
