// ignore_for_file: use_build_context_synchronously

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
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/page_dot_indicator.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_card_widget_parent.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_benefits_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/sunrise_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class RedeemBenefitScreen extends StatefulWidget {
  const RedeemBenefitScreen({
    super.key,
    required this.nearBySpaceEntity,
    this.selectedBenefitEntity,
    this.isMatchedSpaceFound,
  });

  final NearBySpaceEntity nearBySpaceEntity;
  final BenefitEntity? selectedBenefitEntity;
  final bool? isMatchedSpaceFound;

  static push(
    BuildContext context, {
    required NearBySpaceEntity nearBySpaceEntity,
    BenefitEntity? selectedBenefitEntity,
    bool? isMatchedSpaceFound,
  }) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RedeemBenefitScreen(
          nearBySpaceEntity: nearBySpaceEntity,
          selectedBenefitEntity: selectedBenefitEntity,
          isMatchedSpaceFound: isMatchedSpaceFound,
        ),
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
  bool isBenefitRedeemSuccess = false;

  @override
  void initState() {
    super.initState();
    fetchBenefits();
  }

  fetchBenefits() {
    // get Benefits
    getIt<SpaceBenefitsCubit>().onGetSpaceBenefits(
      spaceId: widget.nearBySpaceEntity.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpaceBenefitsCubit, SpaceBenefitsState>(
      bloc: getIt<SpaceBenefitsCubit>(),
      listener: (context, spaceBenefitsState) {},
      builder: (context, spaceBenefitsState) {
        return BlocConsumer<BenefitRedeemCubit, BenefitRedeemState>(
          bloc: getIt<BenefitRedeemCubit>(),
          listener: (context, benefitRedeemState) async {
            if (benefitRedeemState.submitStatus == RequestStatus.failure) {
              // Show Error Snackbar If Error in Redeeming Benefit
              context.showErrorSnackBar(benefitRedeemState.errorMessage);
            }

            if (benefitRedeemState.submitStatus == RequestStatus.success) {
              //update Success Status
              setState(() {
                isBenefitRedeemSuccess = true;
              });
              onBenefitRedeemSuccess(spaceBenefitsState);

              // if selected Entity in not null
              if (widget.selectedBenefitEntity != null) {
                final state = getIt<NftBenefitsCubit>().state;
                //call NFt Benefits API
                getIt<NftBenefitsCubit>()
                    .onGetNftBenefits(tokenAddress: state.selectedTokenAddress);
              }
            }
          },
          builder: (context, benefitRedeemState) {
            return BaseScaffold(
              title: LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
              isCenterTitle: true,
              onBack: () {
                // on Return Press there us need to Re Fetch Benefits
                // if Coming from Home Screen Fetch Its NFT Benefits
                // If Coming from Space Fetch its Space benefits

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
                        const HorizontalSpace(8),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            widget.nearBySpaceEntity.address,
                            style: fontTitle04(),
                          ),
                        ),
                      ],
                    ),
                    widget.isMatchedSpaceFound != null &&
                            widget.isMatchedSpaceFound == false
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DefaultImage(
                                  path: "assets/icons/ic_info_icon.svg",
                                  width: 16,
                                  height: 16,
                                  color: fore2,
                                ),
                                const HorizontalSpace(8),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Text(
                                    LocaleKeys
                                        .notInSpaceCanSpaceCannotUseBenefit
                                        .tr(),
                                    style: fontBodyXs(color: fore2),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 24),
                    if (spaceBenefitsState.isSubmitSuccess)
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
                                  initialPage: selectedPageIndex,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  onPageChanged: (int index, _) {
                                    setState(() {
                                      selectedPageIndex = index;
                                    });
                                  },
                                ),
                                items: widget.selectedBenefitEntity != null
                                    ? [
                                        BenefitCardWidgetParent(
                                          nearBySpaceEntity:
                                              widget.nearBySpaceEntity,
                                          nftBenefitEntity:
                                              widget.selectedBenefitEntity!,
                                          isBenefitRedeemSuccess:
                                              isBenefitRedeemSuccess,
                                        )
                                      ]
                                    : spaceBenefitsState
                                        .benefitGroupEntity.benefits
                                        .map((item) {
                                        return BenefitCardWidgetParent(
                                          nearBySpaceEntity:
                                              widget.nearBySpaceEntity,
                                          nftBenefitEntity: item,
                                        );
                                      }).toList(),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 436),
                    const VerticalSpace(20),
                    widget.selectedBenefitEntity == null
                        ? PageDotIndicator(
                            length: spaceBenefitsState
                                .benefitGroupEntity.benefits.length,
                            selectedIndex: selectedPageIndex,
                          )
                        : const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, top: 50, bottom: 20),
                      child: (benefitRedeemState.submitStatus ==
                              RequestStatus.loading)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SunriseWidget(
                              onSubmitRedeem: () {
                                if (widget.selectedBenefitEntity != null) {
                                  final locationState =
                                      getIt<EnableLocationCubit>().state;
                                  // call the benefit redeem api here

                                  "the token address is as ${widget.selectedBenefitEntity?.tokenAddress}"
                                      .log();

                                  if (locationState.latitude != 0.0 ||
                                      locationState.longitude != 0.0) {
                                    getIt<BenefitRedeemCubit>()
                                        .onPostRedeemBenefit(
                                      benefitId:
                                          widget.selectedBenefitEntity!.id,
                                      tokenAddress: removeCurlyBraces(widget
                                          .selectedBenefitEntity!.tokenAddress),
                                      spaceId:
                                          widget.selectedBenefitEntity!.spaceId,
                                      latitude: 2.0, //locationState.latitude,
                                      longitude: 2.0, //locationState.longitude,
                                    );
                                  }
                                } else {
                                  final selectedBenefit = spaceBenefitsState
                                      .benefitGroupEntity
                                      .benefits[selectedPageIndex];
                                  final locationState =
                                      getIt<EnableLocationCubit>().state;
                                  // call the benefit redeem api here

                                  "the token address is as ${selectedBenefit.tokenAddress}"
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
                                }
                              },
                            ),
                    ),
                  ],
                )),
              ),
            );
          },
        );
      },
    );
  }

  onBenefitRedeemSuccess(SpaceBenefitsState state) async {
    fetchBenefits();
    await showBenefitRedeemSuccessAlertDialog(
      context: context,
      title:
          "${state.benefitGroupEntity.benefits[selectedPageIndex].spaceName}\n${LocaleKeys.youHaveBenefited.tr()}",
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  String removeCurlyBraces(String input) {
    return input.replaceAll(RegExp(r'[{}]'), '');
  }
}
