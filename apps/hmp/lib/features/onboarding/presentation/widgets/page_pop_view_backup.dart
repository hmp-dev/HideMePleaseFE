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
        // const Expanded(
        //   flex: 1,
        //   child: SizedBox(),
        // ),
        // Display the animation.
        Flexible(
          flex: 8,
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Image.asset(onBoardingSlideData.imagePath),
            ),
                // child: SizedBox(
                //   width: 182,
                //   height: 158,
                //   child: Lottie.asset(onBoardingSlideData.animationPath,
                //       fit: BoxFit.contain, alignment: Alignment.center),
                // ),
              //),
          ),
        ),
        // Display the title and subtitle.
        Expanded(
          flex: 2,
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              const VerticalSpace(10),
              Text(
                onBoardingSlideData.titleTextA,
                textAlign: TextAlign.center,
                style: fontTitle05Bold(color: hmpBlue),
              ),
              Text(
                onBoardingSlideData.titleTextB,
                textAlign: TextAlign.center,
                style: fontTitle05Bold(),
              ),
            ],
          ),
        ),
        // Display the description.
        Expanded(
          flex: 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              onBoardingSlideData.descText,
              textAlign: TextAlign.center,
              style: fontCompactSm(color: fore2),
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
  final String imagePath;

  PageViewData({
    required this.titleTextA,
    required this.titleTextB,
    required this.descText,
    required this.animationPath,
    required this.imagePath,
  });
}
