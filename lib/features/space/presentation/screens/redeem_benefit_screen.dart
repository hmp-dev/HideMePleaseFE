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
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_card_widget_with_nearby_space_entityt.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/agree_terms_url_dto.dart';
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart';
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
    if (widget.selectedBenefitEntity == null) {
      getIt<SpaceBenefitsCubit>().onGetSpaceBenefits(
        spaceId: widget.nearBySpaceEntity.id,
      );
    }
  }

  showTermsAlert() {
    if (widget.selectedBenefitEntity != null &&
        widget.selectedBenefitEntity?.termsUrl != "") {
      onShowTermsConcentAlert(widget.selectedBenefitEntity?.termsUrl ?? "");
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
                  if (widget.selectedBenefitEntity != null) {
                    final state = getIt<NftBenefitsCubit>().state;
                    //call NFt Benefits API
                    getIt<NftBenefitsCubit>().onGetNftBenefits(
                        tokenAddress: state.selectedTokenAddress);
                  }
                }
              },
              builder: (context, benefitRedeemState) {
                return BaseScaffold(
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildTitleRow(context),
                          widget.selectedBenefitEntity != null
                              ? Column(
                                  children: [
                                    buildSpaceNameRowWithSpaceNameInBenefit(
                                        context, widget.selectedBenefitEntity!),
                                    widget.isMatchedSpaceFound != null &&
                                            widget.isMatchedSpaceFound == false
                                        ? const NotInSpaceCanSpaceCannotUseBenefit()
                                        : const SizedBox.shrink(),
                                    const SizedBox(height: 24),
                                    if (spaceBenefitsState.isSubmitSuccess ||
                                        widget.selectedBenefitEntity != null)
                                      SizedBox(
                                        height: 436,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: CarouselSlider(
                                                  carouselController:
                                                      _carouselController,
                                                  options: CarouselOptions(
                                                    height: 436,
                                                    viewportFraction: 0.9,
                                                    aspectRatio: 16 / 9,
                                                    enableInfiniteScroll: false,
                                                    enlargeCenterPage: false,
                                                    initialPage:
                                                        selectedPageIndex,
                                                    autoPlayInterval:
                                                        const Duration(
                                                            seconds: 3),
                                                    onPageChanged:
                                                        (int index, _) {
                                                      setState(() {
                                                        selectedPageIndex =
                                                            index;
                                                      });
                                                    },
                                                  ),
                                                  items: [
                                                    BenefitCardWidgetWithNearBySpaceEntity(
                                                      nearBySpaceEntity: widget
                                                          .nearBySpaceEntity,
                                                      nftBenefitEntity: widget
                                                          .selectedBenefitEntity!,
                                                      isBenefitRedeemSuccess:
                                                          isBenefitRedeemSuccess,
                                                      isMatchedSpaceFound: widget
                                                                  .isMatchedSpaceFound ==
                                                              null
                                                          ? true
                                                          : widget.isMatchedSpaceFound ??
                                                              false,
                                                    )
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 436),
                                    const VerticalSpace(20),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0,
                                          right: 20,
                                          top: 50,
                                          bottom: 20),
                                      child: (benefitRedeemState.submitStatus ==
                                              RequestStatus.loading)
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : SunriseWidget(
                                              tokenAddress: removeCurlyBraces(
                                                  widget.selectedBenefitEntity
                                                          ?.tokenAddress ??
                                                      ""),
                                              isButtonEnabled: widget
                                                          .isMatchedSpaceFound ==
                                                      null
                                                  ? true
                                                  : widget.isMatchedSpaceFound ??
                                                      false,
                                              onSubmitRedeem: () async {
                                                final selectedBenefit = widget
                                                    .selectedBenefitEntity!;
                                                submitToRedeemBenefit(
                                                  nearBySpaceState:
                                                      nearBySpaceState,
                                                  selectedBenefit:
                                                      selectedBenefit,
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                )
                              : spaceBenefitsState
                                      .benefitGroupEntity.benefits.isEmpty
                                  ? const SizedBox.shrink()
                                  : Column(
                                      children: [
                                        buildSpaceNameRowWithNearBySpace(
                                            context, widget.nearBySpaceEntity),
                                        widget.isMatchedSpaceFound != null &&
                                                widget.isMatchedSpaceFound ==
                                                    false
                                            ? const NotInSpaceCanSpaceCannotUseBenefit()
                                            : const SizedBox.shrink(),
                                        const SizedBox(height: 24),
                                        if (spaceBenefitsState
                                                .isSubmitSuccess ||
                                            widget.selectedBenefitEntity !=
                                                null)
                                          SizedBox(
                                            height: 436,
                                            child: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20.0),
                                                  child: CarouselSlider(
                                                    carouselController:
                                                        _carouselController,
                                                    options: CarouselOptions(
                                                      height: 436,
                                                      viewportFraction: 0.9,
                                                      aspectRatio: 16 / 9,
                                                      enableInfiniteScroll:
                                                          false,
                                                      enlargeCenterPage: false,
                                                      initialPage:
                                                          selectedPageIndex,
                                                      autoPlayInterval:
                                                          const Duration(
                                                              seconds: 3),
                                                      onPageChanged:
                                                          (int index, _) {
                                                        setState(() {
                                                          selectedPageIndex =
                                                              index;
                                                        });
                                                      },
                                                    ),
                                                    items: spaceBenefitsState
                                                        .benefitGroupEntity
                                                        .benefits
                                                        .map((item) {
                                                      return BenefitCardWidgetWithNearBySpaceEntity(
                                                        nearBySpaceEntity: widget
                                                            .nearBySpaceEntity,
                                                        nftBenefitEntity: item,
                                                        isMatchedSpaceFound:
                                                            item.state ==
                                                                "available",
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
                                        PageDotIndicator(
                                          length: spaceBenefitsState
                                              .benefitGroupEntity
                                              .benefits
                                              .length,
                                          selectedIndex: selectedPageIndex,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              right: 20,
                                              top: 50,
                                              bottom: 20),
                                          child: (benefitRedeemState
                                                      .submitStatus ==
                                                  RequestStatus.loading)
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white)
                                              : SunriseWidget(
                                                  tokenAddress: removeCurlyBraces(
                                                      spaceBenefitsState
                                                          .benefitGroupEntity
                                                          .benefits[
                                                              selectedPageIndex]
                                                          .tokenAddress),
                                                  isButtonEnabled: spaceBenefitsState
                                                          .benefitGroupEntity
                                                          .benefits[
                                                              selectedPageIndex]
                                                          .state ==
                                                      "available",
                                                  onSubmitRedeem: () async {
                                                    final selectedBenefit =
                                                        spaceBenefitsState
                                                                .benefitGroupEntity
                                                                .benefits[
                                                            selectedPageIndex];
                                                    submitToRedeemBenefit(
                                                      nearBySpaceState:
                                                          nearBySpaceState,
                                                      selectedBenefit:
                                                          selectedBenefit,
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void submitToRedeemBenefit({
    required NearBySpacesState nearBySpaceState,
    required BenefitEntity selectedBenefit,
  }) async {
    if (ifUserIsSpace(nearBySpaceState, widget.nearBySpaceEntity)) {
      // redeem submit  starts

      //show info dialogue

      var result = await showBenefitRedeemSuccessAlertDialog(
        context: context,
        buttonTitle: LocaleKeys.employeeConfirmation.tr(),
        title: "직원에게 혜택 사용 화면을 보여주세요!\n${selectedBenefit.description} ",
        onConfirm: () {
          Navigator.pop(context, true);
        },
      );

      if (result) {
        // call the benefit redeem api here

        "the token address is as ${selectedBenefit.tokenAddress}".log();

        getIt<BenefitRedeemCubit>().onPostRedeemBenefit(
          benefitId: selectedBenefit.id,
          tokenAddress: removeCurlyBraces(selectedBenefit.tokenAddress),
          spaceId: selectedBenefit.spaceId,
        );
      }
    } else {
      context.showSnackBar(
        LocaleKeys.notInSpaceCanSpaceCannotUseBenefit.tr(),
      );
    }
  }

  bool ifUserIsSpace(
      NearBySpacesState nearBySpaceState, NearBySpaceEntity nearBySpaceEntity) {
    // bool isUserInSpace = false;
    // for (var space in nearBySpaceState.spacesResponseEntity.spaces) {
    //   if (space.id == nearBySpaceEntity.id) {
    //     isUserInSpace = true;

    //     break;
    //   }
    // }

    // return isUserInSpace;

    return true;
  }

  Row buildSpaceNameRowWithNearBySpace(
    BuildContext context,
    NearBySpaceEntity nearBySpaceEntity,
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
            nearBySpaceEntity.name,
            style: fontTitle04(),
          ),
        ),
      ],
    );
  }

  Row buildSpaceNameRowWithSpaceNameInBenefit(
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
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
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
      title: widget.selectedBenefitEntity == null
          ? "${state.benefitGroupEntity.benefits[selectedPageIndex].spaceName}\n${LocaleKeys.youHaveBenefited.tr()}"
          : "${widget.selectedBenefitEntity?.spaceName}\n${LocaleKeys.youHaveBenefited.tr()}",
      onConfirm: () {
        Navigator.pop(context);
      },
    );

    Navigator.pop(context);
  }

  onShowTermsConcentAlert(String termsUrl) async {
    if (termsUrl != "") {
      final userId = getIt<ProfileCubit>().state.userProfileEntity.id;
      // check if the user has already agreed to the terms
      final hasAgreedTerms = await isUrlAlreadySaved(userId, termsUrl);

      if (!hasAgreedTerms) {
        await showBenefitRedeemAgreeTermsAlertDialog(
          context: context,
          title: LocaleKeys.agreeTermDialogMessage.tr(),
          onConfirm: () {
            Navigator.pop(context);
            WebViewScreen.push(
              context: context,
              title: LocaleKeys.agreeTermsAlertMSG.tr(),
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

class NotInSpaceCanSpaceCannotUseBenefit extends StatelessWidget {
  const NotInSpaceCanSpaceCannotUseBenefit({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              LocaleKeys.notInSpaceCanSpaceCannotUseBenefit.tr(),
              style: fontBodyXs(color: fore2),
            ),
          ),
        ],
      ),
    );
  }
}
