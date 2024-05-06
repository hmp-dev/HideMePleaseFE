import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/helpers/pref_keys.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/onboarding/presentation/widgets/page_pop_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OnBoardingScreen(),
      ),
    );
  }

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _pageController = PageController(initialPage: 0);
  List<PageViewData> pageViewModelData = [];

  var currentSlideIndex = 0;
  bool dontShowCheckBox = false;

  @override
  void initState() {
    pageViewModelData.add(
      PageViewData(
        titleTextA: LocaleKeys.onBoardingSlide1TitleA.tr(),
        titleTextB: LocaleKeys.onBoardingSlide1TitleB.tr(),
        descText: LocaleKeys.onBoardingSlide1Desc.tr(),
        animationPath: "assets/lottie/onboarding1.json",
      ),
    );

    pageViewModelData.add(
      PageViewData(
        titleTextA: LocaleKeys.onBoardingSlide2TitleA.tr(),
        titleTextB: LocaleKeys.onBoardingSlide2TitleB.tr(),
        descText: LocaleKeys.onBoardingSlide2Desc.tr(),
        animationPath: "assets/lottie/onboarding2.json",
      ),
    );

    pageViewModelData.add(
      PageViewData(
          titleTextA: LocaleKeys.onBoardingSlide3TitleA.tr(),
          titleTextB: LocaleKeys.onBoardingSlide3TitleB.tr(),
          descText: LocaleKeys.onBoardingSlide3Desc.tr(),
          animationPath: "assets/lottie/onboarding3.json"),
    );

    pageViewModelData.add(
      PageViewData(
          titleTextA: LocaleKeys.onBoardingSlide4TitleA.tr(),
          titleTextB: LocaleKeys.onBoardingSlide4TitleB.tr(),
          descText: LocaleKeys.onBoardingSlide4Desc.tr(),
          animationPath: "assets/lottie/onboarding4.json"),
    );

    super.initState();
  }

  void _goToNextPage() {
    final currentPage = _pageController.page?.toInt() ?? 0;
    final nextPage = currentPage + 1;

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousPage() {
    // at first swipe back swipedBackCount is 0
    // swipe back and increases swipedBackCount by one

    final currentPage = _pageController.page?.toInt() ?? 0;
    final previousPage = currentPage - 1;
    if (previousPage >= 0) {
      _pageController.animateToPage(
        previousPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    //sliderTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      backgroundColor: bg1,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top +
                    (MediaQuery.of(context).size.height * 0.10),
              ),
              SmoothPageIndicator(
                controller: _pageController, // PageController
                count: pageViewModelData.length,
                effect: const WormEffect(
                    activeDotColor: hmpBlue,
                    dotColor: fore4,
                    dotHeight: 7.0,
                    dotWidth: 7.0,
                    spacing: 5.0), // your preferred effect
                onDotClicked: (index) {},
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  pageSnapping: true,
                  onPageChanged: (index) {
                    setState(() {
                      currentSlideIndex = index;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    PagePopup(onBoardingSlideData: pageViewModelData[0]),
                    PagePopup(onBoardingSlideData: pageViewModelData[1]),
                    PagePopup(onBoardingSlideData: pageViewModelData[2]),
                    PagePopup(onBoardingSlideData: pageViewModelData[3]),
                  ],
                ),
              ),
              currentSlideIndex + 1 == pageViewModelData.length
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            dontShowCheckBox = !dontShowCheckBox;
                          });

                          // setDontShowAgain value in local storage
                          setDontShowAgain(dontShowCheckBox);

                          Log.info("dontShowAgain: $dontShowCheckBox");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: dontShowCheckBox,
                              onChanged: (bool? value) {
                                setState(() {
                                  dontShowCheckBox = value ?? false;
                                });

                                setDontShowAgain(dontShowCheckBox);
                              },
                            ),
                            Text(LocaleKeys.dontShowNextTimeMsg.tr(),
                                style: fontCompactSm(color: fore3)),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              currentSlideIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: HMPCustomButton(
                        text: LocaleKeys.next.tr(),
                        onPressed: _goToNextPage,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RoundedButtonWithBorder(
                              text: LocaleKeys.previous.tr(),
                              onPressed: _goToPreviousPage,
                            ),
                          ),
                          const HorizontalSpace(20),
                          Expanded(
                            child: currentSlideIndex + 1 ==
                                    pageViewModelData.length
                                ? HMPCustomButton(
                                    text: LocaleKeys.confirm.tr(),
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Routes.startUpScreen,
                                        (route) => false,
                                      );
                                    },
                                  )
                                : HMPCustomButton(
                                    text: LocaleKeys.next.tr(),
                                    onPressed: _goToNextPage,
                                  ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 30,
              ),
            ],
          ),
        ],
      ),
    );
  }

  setDontShowAgain(bool isDontShow) async {
    final prefs = await SharedPreferences.getInstance();
    if (isDontShow) {
      await prefs.setInt(isShowOnBoardingView, 1);
    } else {
      await prefs.setInt(isShowOnBoardingView, 0);
    }

    var isShowOnBoarding = prefs.getInt(isShowOnBoardingView);
    Log.info("isShowOnBoarding: $isShowOnBoarding");
  }
}
