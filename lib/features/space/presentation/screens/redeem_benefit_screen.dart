// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/animated_swipe/swipeable_button_view.dart';
import 'package:mobile/app/core/helpers/flutter_touch_ripple/components/behavior.dart';
import 'package:mobile/app/core/helpers/flutter_touch_ripple/widgets/widget.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/page_dot_indicator.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_card_widget_parent.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart';
import 'package:mobile/features/space/presentation/views/confirm_page.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:page_transition/page_transition.dart';

class CalculatorStyles {
  static const double headerPadding = 50;
  static const double innerPadding = 5;
  static const Color titleColor = Colors.white;
  static const Color subColor = Color.fromRGBO(225, 225, 225, 1);
  static const Color descriptionColor = Color.fromRGBO(160, 160, 160, 1);
  static const Color foregroundColor = Color.fromRGBO(16, 16, 16, 1);
  static const Color foregroundColor2 = Color.fromRGBO(32, 32, 32, 1);
}

class RedeemBenefitScreen extends StatefulWidget {
  const RedeemBenefitScreen({
    super.key,
    required this.nearBySpaceEntity,
    required this.selectedNftTokenAddress,
  });

  final NearBySpaceEntity nearBySpaceEntity;
  final String selectedNftTokenAddress;

  static push(BuildContext context, NearBySpaceEntity nearBySpaceEntity,
      String selectedNftTokenAddress) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RedeemBenefitScreen(
            nearBySpaceEntity: nearBySpaceEntity,
            selectedNftTokenAddress: selectedNftTokenAddress),
      ),
    );
  }

  @override
  State<RedeemBenefitScreen> createState() => _RedeemBenefitScreenState();
}

class _RedeemBenefitScreenState extends State<RedeemBenefitScreen> {
  final CarouselController _carouselController = CarouselController();

  String selectedBenefitId = "";
  int selectedPageIndex = 0;

  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    fetchBenefits();
  }

  fetchBenefits() {
    // get Benefits
    getIt<NftCubit>().onGetNftBenefits(
      tokenAddress: widget.selectedNftTokenAddress,
      spaceId: widget.nearBySpaceEntity.id,
      isShowLoading: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return BaseScaffold(
          title: LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
          isCenterTitle: true,
          onBack: () {
            Navigator.pop(context);
          },
          backIconPath: 'assets/icons/ic_close.svg',
          body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultImage(
                      path: "assets/icons/ic_space_enabled.svg",
                      width: 32,
                      height: 32,
                      color: white,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        widget.nearBySpaceEntity.address,
                        style: fontTitle04(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.isSubmitSuccess)
                  SizedBox(
                    height: 436,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: 436,
                              viewportFraction: 0.9,
                              aspectRatio: 16 / 9,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: false,
                              autoPlayInterval: const Duration(seconds: 3),
                              onPageChanged: (int index, _) {
                                setState(() {
                                  selectedPageIndex = index;
                                  selectedBenefitId =
                                      state.nftBenefitList[index].id;
                                });
                              },
                            ),
                            items: state.nftBenefitList.map((item) {
                              return BenefitCardWidgetParent(
                                nearBySpaceEntity: widget.nearBySpaceEntity,
                                selectedNftTokenAddress:
                                    widget.selectedNftTokenAddress,
                                nftBenefitEntity: item,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                const VerticalSpace(20),
                PageDotIndicator(
                  length: state.nftBenefitList.length,
                  selectedIndex: selectedPageIndex,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, top: 50, bottom: 20),
                  child: BlocConsumer<BenefitRedeemCubit, BenefitRedeemState>(
                    bloc: getIt<BenefitRedeemCubit>(),
                    listener: (context, benefitRedeemState) async {
                      if (benefitRedeemState.isFailure) {
                        // Show Error Snackbar If Error in Redeeming Benefit
                        // context.showErrorSnackBar(spaceState.errorMessage);
                        // await Future.delayed(const Duration(seconds: 2));
                        // setState(() => isFinished = true);

                        onBenefitRedeemSuccess(state);
                      }

                      if (benefitRedeemState.isSuccess) {
                        onBenefitRedeemSuccess(state);
                      }
                    },
                    builder: (context, benefitRedeemState) {
                      return (benefitRedeemState.submitStatus ==
                              RequestStatus.loading)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SunriseWidget(
                              onSubmitRedeem: () {
                                setState(() => isFinished = false);
                                final selectedBenefitId =
                                    state.nftBenefitList[selectedPageIndex];
                                final locationState =
                                    getIt<EnableLocationCubit>().state;
                                // call the benefit redeem api here
                                if (locationState.latitude != 0.0 ||
                                    locationState.longitude != 0.0) {
                                  getIt<BenefitRedeemCubit>()
                                      .onPostRedeemBenefit(
                                    benefitId: selectedBenefitId.id,
                                    tokenAddress:
                                        selectedBenefitId.tokenAddress,
                                    spaceId: widget.nearBySpaceEntity.id,
                                    latitude: 2.0, //locationState.latitude,
                                    longitude: 2.0, //locationState.longitude,
                                  );
                                }
                              },
                            );
                    },
                  ),
                ),
              ],
            )),
          ),
        );
      },
    );
  }

  onBenefitRedeemSuccess(NftState state) async {
    final result = await showBenefitRedeemSuccessAlertDialog(
      context: context,
      title:
          "@${state.nftBenefitList[selectedPageIndex].spaceName}\n${LocaleKeys.youHaveBenefited.tr()}",
      onConfirm: () {
        Navigator.pop(context);
      },
    );

    if (result) {
      // refetch all benefits
      fetchBenefits();
    } else {
      // refetch all benefits
      fetchBenefits();
    }
  }
}

class SunriseWidget extends StatefulWidget {
  const SunriseWidget({super.key, required this.onSubmitRedeem});

  final VoidCallback onSubmitRedeem;

  @override
  State<SunriseWidget> createState() => _SunriseWidgetState();
}

class _SunriseWidgetState extends State<SunriseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _fillFull = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2, milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 54).animate(_controller)
      ..addListener(() {
        if (_animation.value >= 54) {
          setState(() {
            _fillFull = true;
          });
        }
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPress() {
    _fillFull = false;
    _controller.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) async {
    widget.onSubmitRedeem();
    setState(() {
      _fillFull = true;
    });

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _onLongPress,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        children: [
          Container(
            height: 54,
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
              color: backgroundGr1,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
                style: fontCompactMd(),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ClipPath(
                clipper:
                    _fillFull ? FullClipper() : CurveClipper(_animation.value),
                child: Container(
                  height: 54,
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: fore3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  final double height;

  CurveClipper(this.height);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height - height * 2, size.width, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CurveClipper oldClipper) {
    return oldClipper.height != height;
  }
}

class FullClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
