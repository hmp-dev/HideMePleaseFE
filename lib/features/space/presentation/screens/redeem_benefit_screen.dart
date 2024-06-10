// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/animated_swipe/swipeable_button_view.dart';
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
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/views/confirm_page.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:page_transition/page_transition.dart';

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
                              viewportFraction: 0.72,
                              aspectRatio: 16 / 9,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: false,
                              enlargeFactor: 0.12,
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
                  child: BlocConsumer<SpaceCubit, SpaceState>(
                    bloc: getIt<SpaceCubit>(),
                    listener: (context, spaceState) async {
                      if (spaceState.isFailure) {
                        // Show Error Snackbar If Error in Redeeming Benefit
                        // context.showErrorSnackBar(spaceState.errorMessage);
                        // await Future.delayed(const Duration(seconds: 2));
                        // setState(() => isFinished = true);

                        onBenefitRedeemSuccess(state);
                      }

                      if (spaceState.isSuccess) {
                        onBenefitRedeemSuccess(state);
                      }
                    },
                    builder: (context, spaceState) {
                      return SwipeableButtonView(
                        onFinish: () {},
                        onWaitingProcessError: () async {},
                        onWaitingProcessSuccess: () async {},
                        activeColor: backgroundGr1,
                        buttonTextStyle: fontCompactMd(),
                        buttonWidget: const SizedBox.shrink(),
                        buttonText: LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
                        isFinished: isFinished,
                        onPressed: () {
                          setState(() => isFinished = false);
                          final selectedBenefitId =
                              state.nftBenefitList[selectedPageIndex].id;
                          final locationState =
                              getIt<EnableLocationCubit>().state;
                          // call the benefit redeem api here
                          if (locationState.latitude != 0.0 ||
                              locationState.longitude != 0.0) {
                            getIt<SpaceCubit>().onPostRedeemBenefit(
                              benefitId: selectedBenefitId,
                              tokenAddress: widget.selectedNftTokenAddress,
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
    //=====
    final result = await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: const ConfirmationPage(),
      ),
    );

    setState(() => isFinished = true);

    // Handle the result
    if (result != null) {
      // refetch all benefits
      fetchBenefits();

      showBenefitRedeemSuccessAlertDialog(
        context: context,
        title:
            "@${state.nftBenefitList[selectedPageIndex].spaceName}\n${LocaleKeys.youHaveBenefited.tr()}",
        onConfirm: () {
          Navigator.pop(context);
        },
      );
    }
  }
}
