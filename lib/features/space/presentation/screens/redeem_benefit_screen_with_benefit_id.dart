// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/page_dot_indicator.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/benefit_redeem_card_widget_parent.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class RedeemBenefitScreenWithBenefitId extends StatefulWidget {
  const RedeemBenefitScreenWithBenefitId({
    super.key,
    required this.benefitEntity,
    required this.spaceDetailEntity,
  });

  final BenefitEntity benefitEntity;
  final SpaceDetailEntity spaceDetailEntity;

  static push(BuildContext context, BenefitEntity benefitEntity,
      SpaceDetailEntity spaceDetailEntity) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RedeemBenefitScreenWithBenefitId(
            benefitEntity: benefitEntity, spaceDetailEntity: spaceDetailEntity),
      ),
    );
  }

  @override
  State<RedeemBenefitScreenWithBenefitId> createState() =>
      _RedeemBenefitScreenWithBenefitIdState();
}

class _RedeemBenefitScreenWithBenefitIdState
    extends State<RedeemBenefitScreenWithBenefitId> {
  final CarouselController _carouselController = CarouselController();

  String selectedBenefitId = "";
  int selectedPageIndex = 0;
  late BenefitEntity selectedBenefitEntity;

  @override
  void initState() {
    super.initState();
    fetchBenefits();
    selectedBenefitEntity = widget.benefitEntity;
  }

  fetchBenefits() {
    getIt<SpaceCubit>()
        .onGetSpaceBenefits(spaceId: widget.benefitEntity.spaceId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpaceCubit, SpaceState>(
      bloc: getIt<SpaceCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return BaseScaffold(
          title: LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
          isCenterTitle: true,
          onBack: () {
            Navigator.of(context).pop();
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
                        widget.spaceDetailEntity.address,
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
                              initialPage: state.benefitsGroupEntity.benefits
                                  .indexOf(widget.benefitEntity),
                              autoPlayInterval: const Duration(seconds: 3),
                              onPageChanged: (int index, _) {
                                setState(() {
                                  selectedPageIndex = index;
                                  selectedBenefitEntity =
                                      state.benefitsGroupEntity.benefits[index];
                                });
                              },
                            ),
                            items:
                                state.benefitsGroupEntity.benefits.map((item) {
                              return BenefitRedeemCardWidgetParent(
                                spaceDetailEntity: widget.spaceDetailEntity,
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
                  length: state.benefitsGroupEntity.benefits.length,
                  selectedIndex: getSelectedIndex(state),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, top: 50, bottom: 20),
                  child: BlocConsumer<BenefitRedeemCubit, BenefitRedeemState>(
                    bloc: getIt<BenefitRedeemCubit>(),
                    listener: (context, benefitRedeemState) async {
                      if (benefitRedeemState.submitStatus ==
                          RequestStatus.failure) {
                        //Show Error Snackbar If Error in Redeeming Benefit
                        context
                            .showErrorSnackBar(benefitRedeemState.errorMessage);
                      }

                      if (benefitRedeemState.submitStatus ==
                          RequestStatus.success) {
                        onBenefitRedeemSuccess(state);
                      }
                    },
                    builder: (context, benefitRedeemState) {
                      return (benefitRedeemState.submitStatus ==
                              RequestStatus.loading)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SunriseWidget(
                              onSubmitRedeem: () {
                                final receivedBenefitIndex = state
                                    .benefitsGroupEntity.benefits
                                    .indexOf(widget.benefitEntity);

                                final selectedBenefit =
                                    (selectedPageIndex == receivedBenefitIndex)
                                        ? state.benefitsGroupEntity
                                            .benefits[selectedPageIndex]
                                        : state.benefitsGroupEntity
                                            .benefits[receivedBenefitIndex];

                                final locationState =
                                    getIt<EnableLocationCubit>().state;
                                // call the benefit redeem api here

                                "selectedBenefitId is ${selectedBenefit.id}"
                                    .log();
                                if (locationState.latitude != 0.0 ||
                                    locationState.longitude != 0.0) {
                                  getIt<BenefitRedeemCubit>()
                                      .onPostRedeemBenefit(
                                    benefitId: selectedBenefit.id,
                                    tokenAddress: removeCurlyBraces(
                                        selectedBenefit.tokenAddress),
                                    spaceId: selectedBenefit.spaceId,
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

  int getSelectedIndex(SpaceState state) {
    return state.benefitsGroupEntity.benefits.indexOf(selectedBenefitEntity);
  }

  onBenefitRedeemSuccess(SpaceState state) async {
    final result = await showBenefitRedeemSuccessAlertDialog(
      context: context,
      title:
          "@${state.benefitsGroupEntity.benefits[getSelectedIndex(state)].spaceName}\n${LocaleKeys.youHaveBenefited.tr()}",
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

  String removeCurlyBraces(String input) {
    return input.replaceAll(RegExp(r'[{}]'), '');
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

  Timer? _timer;
  bool _isPressed = false;
  bool _longPressSuccess = false;
  static const int requiredPressDuration = 2500; // in milliseconds

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

  // Press timer

  void _startTimer() {
    _timer = Timer(const Duration(milliseconds: requiredPressDuration), () {
      if (_isPressed) {
        if (mounted) {
          setState(() {
            _longPressSuccess = true;
          });
        }
      }
    });
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
    setState(() {
      _isPressed = false;
      _longPressSuccess = false;
    });
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _fillFull = false;
    _controller.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      widget.onSubmitRedeem();
      setState(() {
        _fillFull = true;
      });

      _controller.reset();
    });

    setState(() {
      _isPressed = true;
    });
    _startTimer();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!_longPressSuccess) {
      _controller.reverse();
    }
    _cancelTimer();
  }

  @override
  void dispose() {
    _cancelTimer();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
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
                LocaleKeys.longPressToUseBenefits.tr(),
                style: fontCompactMd(),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ClipPath(
                clipper: _fillFull
                    ? CenterExpandClipper(
                        MediaQuery.of(context).size.width - 40)
                    : CurveClipper(_animation.value),
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

class CenterExpandClipper extends CustomClipper<Path> {
  final double expansion;

  CenterExpandClipper(this.expansion);

  @override
  Path getClip(Size size) {
    var path = Path();
    double centerX = size.width / 2;
    path.moveTo(centerX - expansion, size.height);
    path.lineTo(centerX + expansion, size.height);
    path.lineTo(centerX + expansion, 0);
    path.lineTo(centerX - expansion, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CenterExpandClipper oldClipper) {
    return oldClipper.expansion != expansion;
  }
}
