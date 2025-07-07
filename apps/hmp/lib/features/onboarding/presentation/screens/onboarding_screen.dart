import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/pref_keys.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/onboarding/presentation/widgets/page_pop_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// OnBoardingScreen is a stateful widget that represents the onboarding screen.
///
/// It is responsible for displaying the onboarding slides to the user.
/// The widget is implemented using the stateful widget pattern where the
/// state is managed by the [_OnBoardingScreenState] class.
class OnBoardingScreen extends StatefulWidget {
  /// Creates a new instance of [OnBoardingScreen].
  ///
  /// The [key] parameter is used to uniquely identify the widget throughout the
  /// widget tree.
  const OnBoardingScreen({super.key});

  /// Pushes the [OnBoardingScreen] widget to the navigation stack.
  ///
  /// This method takes a [BuildContext] as a parameter and returns a [Future]
  /// that resolves to the result of the navigation. The widget is wrapped in a
  /// [MaterialPageRoute] and pushed onto the navigation stack using the
  /// [Navigator.push] method.
  static Future<T?> push<T extends Object?>(BuildContext context) async {
    return await Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const OnBoardingScreen(),
      ),
    );
  }

  /// Creates the mutable state for this widget at a given location in the tree.
  ///
  /// This method is called when inflating the widget's element, and should
  /// return a new instance of the associated [State] class.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] subclass.
  ///
  /// The framework will call this method multiple times over the lifetime of
  /// a [StatefulWidget], for example when the widget is inserted into the
  /// tree, when the widget is updated, or when the widget is removed from the
  /// tree. It is therefore critical that the [createState] method return
  /// consistently distinct objects.
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _pageController = PageController(initialPage: 0);
  List<PageViewData> pageViewModelData = [];

  var currentSlideIndex = 0;
  bool dontShowCheckBox = false;
  bool _isConfirming = false;
  // to prevent double tap while in process to check location and navigate

  @override
  void initState() {
    pageViewModelData.add(
      PageViewData(
        titleTextA: LocaleKeys.onBoardingSlide1TitleA.tr(),
        titleTextB: LocaleKeys.onBoardingSlide1TitleB.tr(),
        descText: LocaleKeys.onBoardingSlide1Desc.tr(),
        animationPath: "assets/lottie/onboarding1.json",
        imagePath: "assets/images/onboarding01.png"
      ),
    );

    // pageViewModelData.add(
    //   PageViewData(
    //     titleTextA: LocaleKeys.onBoardingSlide2TitleA.tr(),
    //     titleTextB: LocaleKeys.onBoardingSlide2TitleB.tr(),
    //     descText: LocaleKeys.onBoardingSlide2Desc.tr(),
    //     animationPath: "assets/lottie/onboarding2.json",
    //   ),
    // );

    pageViewModelData.add(
      PageViewData(
          titleTextA: LocaleKeys.onBoardingSlide3TitleA.tr(),
          titleTextB: LocaleKeys.onBoardingSlide3TitleB.tr(),
          descText: LocaleKeys.onBoardingSlide3Desc.tr(),
          animationPath: "assets/lottie/onboarding3.json",
          imagePath: "assets/images/onboarding02.png"
      ),
    );

    pageViewModelData.add(
      PageViewData(
          titleTextA: LocaleKeys.onBoardingSlide4TitleA.tr(),
          titleTextB: LocaleKeys.onBoardingSlide4TitleB.tr(),
          descText: LocaleKeys.onBoardingSlide4Desc.tr(),
          animationPath: "assets/lottie/onboarding4.json",
          imagePath: "assets/images/onboarding03.png"
      ),
    );

    // call function to check if location is enabled
    getIt<EnableLocationCubit>().checkLocationEnabled();

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
      // convert BlocListener to BlocConsumer

      body: BlocConsumer<EnableLocationCubit, EnableLocationState>(
        bloc: getIt<EnableLocationCubit>(),
        listener: (context, state) {
          if (state.submitStatus == RequestStatus.success) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.startUpScreen,
              (route) => false,
            );
          }

          if ((state.submitStatus == RequestStatus.failure) &&
              state.isLocationDenied) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.startUpScreen,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,// +(MediaQuery.of(context).size.height * 0.10
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
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
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
                      ],
                    ),
                  ),
                  currentSlideIndex + 1 == pageViewModelData.length
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                dontShowCheckBox = !dontShowCheckBox;
                              });

                              // setDontShowAgain value in local storage
                              setDontShowAgain(dontShowCheckBox);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  side: const BorderSide(color: fore3),
                                  activeColor: hmpBlue,
                                  checkColor: white,
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
                              const HorizontalSpace(10),
                              Expanded(
                                child: currentSlideIndex + 1 ==
                                        pageViewModelData.length
                                    ? HMPCustomButton(
                                        text: LocaleKeys.confirmStart.tr(),
                                        bgColor: hmpBlue,
                                        onPressed: _isConfirming
                                            ? () {}
                                            : () async {
                                                setState(
                                                    () => _isConfirming = true);

                                                // check if Location is already enabled

                                                if (state.isLocationEnabled) {
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                    context,
                                                    Routes.startUpScreen,
                                                    (route) => false,
                                                  );

                                                  setState(() =>
                                                      _isConfirming = false);
                                                } else {
                                                  setState(() =>
                                                      _isConfirming = false);

                                                  "onBoardingScreen tapped on Confirm Button"
                                                      .log();

                                                  await showHmpAlertDialog(
                                                    context: context,
                                                    title: LocaleKeys
                                                        .allowLocationPermission
                                                        .tr(),
                                                    content: LocaleKeys
                                                        .locationAlertMessage
                                                        .tr(),
                                                    onConfirm: () {
                                                      Navigator.pop(context);
                                                      // Ask for device location
                                                      getIt<EnableLocationCubit>()
                                                          .onAskDeviceLocation();
                                                    },
                                                  );
                                                }
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
          );
        },
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
    ("isShowOnBoarding: $isShowOnBoarding").log();
  }
}
