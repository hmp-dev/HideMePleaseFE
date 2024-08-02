// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/constants/app_constants.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_card_widget_with_space_detail_entity.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/agree_terms_url_dto.dart';
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_benefits_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/sunrise_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// A screen that allows the user to redeem a benefit in a specific space.
///
/// This screen is used when the user has already found a space that offers
/// the selected benefit.
///
/// The [space] parameter represents the specific space in which the benefit
/// is being redeemed.
/// The [benefit] parameter represents the specific benefit that is being
/// redeemed.
/// The [isMatchedSpaceFound] parameter indicates whether the user has already
/// found a space that offers the selected benefit.
class RedeemBenefitScreenWithSpace extends StatefulWidget {
  // Constructor for RedeemBenefitScreenWithSpace
  const RedeemBenefitScreenWithSpace({
    super.key,
    required this.space, // The specific space in which the benefit is being redeemed
    required this.benefit, // The specific benefit that is being redeemed
    required this.isMatchedSpaceFound, // Indicates whether the user has already found a space that offers the selected benefit
  });

  /// The specific space in which the benefit is being redeemed
  final SpaceDetailEntity space;

  /// The specific benefit that is being redeemed
  final BenefitEntity benefit;

  /// Indicates whether the user has already found a space that offers the selected benefit
  final bool isMatchedSpaceFound;

  /// Pushes the RedeemBenefitScreenWithSpace to the navigation stack.
  ///
  /// The [context] parameter represents the build context.
  /// The [space] parameter represents the specific space in which the benefit
  /// is being redeemed.
  /// The [benefit] parameter represents the specific benefit that is being
  /// redeemed.
  /// The [isMatchedSpaceFound] parameter indicates whether the user has already
  /// found a space that offers the selected benefit.
  static Future<dynamic> push(
    BuildContext context, {
    required SpaceDetailEntity space,
    required BenefitEntity selectedBenefitEntity,
    required bool isMatchedSpaceFound,
  }) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RedeemBenefitScreenWithSpace(
          space: space,
          benefit: selectedBenefitEntity,
          isMatchedSpaceFound: isMatchedSpaceFound,
        ),
      ),
    );
  }

  @override
  State<RedeemBenefitScreenWithSpace> createState() =>
      _RedeemBenefitScreenWithSpaceState();
}

class _RedeemBenefitScreenWithSpaceState
    extends State<RedeemBenefitScreenWithSpace> {
  final CarouselController _carouselController = CarouselController();

  String selectedBenefitId = "";
  int selectedPageIndex = 0;
  bool isFinished = false;
  bool isBenefitRedeemSuccess = false;

  @override
  void initState() {
    super.initState();
  }

  showTermsAlert() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (widget.benefit.termsUrl != "") {
      onShowTermsConcentAlert(widget.benefit.termsUrl);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showTermsAlert();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NearBySpacesCubit, NearBySpacesState>(
      bloc: getIt<NearBySpacesCubit>(),
      listener: (context, nearBySpaceState) {},
      builder: (context, nearBySpaceState) {
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
                  final state = getIt<NftBenefitsCubit>().state;
                  //call NFt Benefits API
                  getIt<NftBenefitsCubit>().onGetNftBenefits(
                      tokenAddress: state.selectedTokenAddress);
                }
              },
              builder: (context, benefitRedeemState) {
                return Scaffold(
                  body: SafeArea(
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildTitleRow(context),
                        buildSpaceNameRow(context, widget.space),
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
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
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
                                    autoPlayInterval:
                                        const Duration(seconds: 3),
                                    onPageChanged: (int index, _) {
                                      setState(() {
                                        selectedPageIndex = index;
                                      });
                                    },
                                  ),
                                  items: [
                                    BenefitCardWidgetWithSpaceDetailEntity(
                                      space: widget.space,
                                      nftBenefitEntity: widget.benefit,
                                      isBenefitRedeemSuccess:
                                          isBenefitRedeemSuccess,
                                      isMatchedSpaceFound:
                                          widget.isMatchedSpaceFound
                                              ? true
                                              : widget.isMatchedSpaceFound,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const VerticalSpace(20),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, top: 50, bottom: 20),
                          child: (benefitRedeemState.submitStatus ==
                                  RequestStatus.loading)
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : SunriseWidget(
                                  tokenAddress: removeCurlyBraces(
                                      widget.benefit.tokenAddress),
                                  isButtonEnabled: widget.isMatchedSpaceFound,
                                  onSubmitRedeem: () async {
                                    // bool isUserInSpace = false;
                                    // for (var space in nearBySpaceState
                                    //     .spacesResponseEntity.spaces) {
                                    //   if (space.id == widget.space.id) {
                                    //     isUserInSpace = true;

                                    //     break;
                                    //   }
                                    // }

                                    // await Future.delayed(
                                    //     const Duration(milliseconds: 100));

                                    //if (isUserInSpace) {
                                    // redeem submit  starts
                                    var result =
                                        await showBenefitRedeemSuccessAlertDialog(
                                      context: context,
                                      buttonTitle:
                                          LocaleKeys.employeeConfirmation.tr(),
                                      title:
                                          "직원에게 혜택 사용 화면을 보여주세요!\n${widget.benefit.description} ",
                                      onConfirm: () {
                                        Navigator.pop(context, true);
                                      },
                                    );

                                    if (result) {
                                      "the token address is as ${widget.benefit.tokenAddress}"
                                          .log();

                                      getIt<BenefitRedeemCubit>()
                                          .onPostRedeemBenefit(
                                        benefitId: widget.benefit.id,
                                        tokenAddress: removeCurlyBraces(
                                            widget.benefit.tokenAddress),
                                        spaceId: widget.benefit.spaceId,
                                      );
                                    }
                                    // } else {
                                    //   context.showSnackBar(
                                    //     LocaleKeys
                                    //         .notInSpaceCanSpaceCannotUseBenefit
                                    //         .tr(),
                                    //   );
                                    // }

                                    // redeem submit  Ends
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
      },
    );
  }

  Row buildSpaceNameRow(
    BuildContext context,
    SpaceDetailEntity space,
  ) {
    return Row(
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
            space.name,
            style: fontTitle04(),
          ),
        ),
      ],
    );
  }

  Row buildSpaceNameRowWithBenefit(
    BuildContext context,
    BenefitEntity benefitEntity,
  ) {
    return Row(
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
            benefitEntity.spaceName,
            style: fontTitle04(),
          ),
        ),
      ],
    );
  }

  Padding buildTitleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: DefaultImage(
              path: 'assets/icons/ic_close.svg',
              width: 32,
              height: 32,
              color: white,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
                  style: fontTitle05Medium(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onBenefitRedeemSuccess(SpaceBenefitsState state) async {
    await Future.delayed(const Duration(milliseconds: 200));
    //fetchBenefits();
    await showBenefitRedeemSuccessAlertDialog(
      context: context,
      buttonTitle: LocaleKeys.confirm.tr(),
      title: "${widget.benefit.spaceName}\n${LocaleKeys.youHaveBenefited.tr()}",
      onConfirm: () {
        Navigator.pop(context);
      },
    );

    Navigator.pop(context);
  }

  onShowTermsConcentAlert(String termsUrl) async {
    if (termsUrl != "") {
      final userId = getIt<ProfileCubit>().state.userProfileEntity.id;
      //check if the user has already agreed to the terms
      final hasAgreedTerms = await isUrlAlreadySaved(userId, termsUrl);

      if (!hasAgreedTerms) {
        await showBenefitRedeemAgreeTermsAlertDialog(
          context: context,
          //title: LocaleKeys.agreeTermDialogMessage.tr(),
          title: invitationModelTile,
          onConfirm: () {
            Navigator.pop(context);
            WebViewScreen.push(
              context: context,
              //title: LocaleKeys.agreeTermsAlertMSG.tr(),
              title: "이벤트 참여 양식", // Event Participation Form
              url: termsUrl,
            );
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      } else {
        var result = await getAgreeTermsVisitedUrlDtoList();

        for (var obj in result) {
          "save url is: ${obj.termsUrl}".log();
          "save userId is: ${obj.userId}".log();
        }
      }
    }
  }

  String removeCurlyBraces(String input) {
    return input.replaceAll(RegExp(r'[{}]'), '');
  }
}
