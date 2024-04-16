import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/pref_keys.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_check_button.dart';
import 'package:mobile/features/common/presentation/widgets/default_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
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
        titleText: LocaleKeys.welcomeNFT.tr(),
        subText: LocaleKeys.onBaordingMessageWelcomeSlide.tr(),
        imagePath: "assets/images/iPhone-13-Pro-Front.png",
      ),
    );

    pageViewModelData.add(
      PageViewData(
        titleText: LocaleKeys.community.tr(),
        subText: LocaleKeys.onBoardingMessageCommunitySlide.tr(),
        imagePath: "assets/images/iPhone-13-Pro-Front.png",
      ),
    );

    pageViewModelData.add(
      PageViewData(
          titleText: LocaleKeys.event.tr(),
          subText: LocaleKeys.onBoardingMessageEventSlide.tr(),
          imagePath: "assets/images/iPhone-13-Pro-Front.png"),
    );

    pageViewModelData.add(
      PageViewData(
          titleText: LocaleKeys.spaceAndBenefits.tr(),
          subText: LocaleKeys.onBoardingMessageSpaceAndBenefitsSlide.tr(),
          imagePath: "assets/images/iPhone-13-Pro-Front.png"),
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
      backgroundColor: lightGray,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      pageSnapping: true,
                      onPageChanged: (index) {
                        setState(() {
                          currentSlideIndex = index;
                        });
                      },
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        PagePopup(imageData: pageViewModelData[0]),
                        PagePopup(imageData: pageViewModelData[1]),
                        PagePopup(imageData: pageViewModelData[2]),
                        PagePopup(imageData: pageViewModelData[3]),
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 150, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            currentSlideIndex != 0
                                ? DefaultIconButton(
                                    iconPath: "assets/icons/ic_caret_left.svg",
                                    onTap: _goToPreviousPage,
                                  )
                                : const SizedBox.shrink(),
                            currentSlideIndex + 1 < pageViewModelData.length
                                ? DefaultIconButton(
                                    iconPath: "assets/icons/ic_caret_right.svg",
                                    onTap: _goToNextPage,
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController, // PageController
                count: pageViewModelData.length,
                effect: const WormEffect(
                    activeDotColor: pureBlack,
                    dotColor: lighterGray,
                    dotHeight: 7.0,
                    dotWidth: 7.0,
                    spacing: 5.0), // your preferred effect
                onDotClicked: (index) {},
              ),
              const VerticalSpace(30),
              currentSlideIndex + 1 == pageViewModelData.length
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            dontShowCheckBox = !dontShowCheckBox;
                          });

                          // setDontShowAgain value in local storage
                          setDontShowAgain(dontShowCheckBox);
                        },
                        child: Row(
                          children: [
                            DefaultCheckButton(
                              isSelected: dontShowCheckBox,
                              size: 18,
                              borderRadius: 0,
                            ),
                            Text(LocaleKeys.dontShowNextTimeMsg.tr(),
                                style: fontR(14, color: pureBlack)),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              currentSlideIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: RoundedButton(
                        text: LocaleKeys.next.tr(),
                        onPressed: _goToNextPage,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.42,
                            child: RoundedButtonWithBorder(
                              text: LocaleKeys.previous.tr(),
                              onPressed: _goToPreviousPage,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.42,
                            child: currentSlideIndex + 1 ==
                                    pageViewModelData.length
                                ? RoundedButton(
                                    text: LocaleKeys.confirm.tr(),
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Routes.startUpScreen,
                                        (route) => false,
                                      );
                                    },
                                  )
                                : RoundedButton(
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
