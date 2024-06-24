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
import 'package:mobile/features/common/presentation/widgets/page_dot_indicator.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/presentation/cubit/benefit_redeem_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_benefits_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/benefit_redeem_card_widget_parent.dart';
import 'package:mobile/features/space/presentation/widgets/sunrise_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class RedeemBenefitScreenFromBenefitTap extends StatefulWidget {
  const RedeemBenefitScreenFromBenefitTap({
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
        builder: (_) => RedeemBenefitScreenFromBenefitTap(
            benefitEntity: benefitEntity, spaceDetailEntity: spaceDetailEntity),
      ),
    );
  }

  @override
  State<RedeemBenefitScreenFromBenefitTap> createState() =>
      _RedeemBenefitScreenFromBenefitTapState();
}

class _RedeemBenefitScreenFromBenefitTapState
    extends State<RedeemBenefitScreenFromBenefitTap> {
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
    getIt<SpaceBenefitsCubit>()
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
                (state.isSubmitSuccess)
                    ? SizedBox(
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
                                  initialPage: state
                                      .benefitsGroupEntity.benefits
                                      .indexOf(widget.benefitEntity),
                                  autoPlayInterval: const Duration(seconds: 3),
                                  onPageChanged: (int index, _) {
                                    setState(() {
                                      selectedPageIndex = index;
                                      selectedBenefitEntity = state
                                          .benefitsGroupEntity.benefits[index];
                                    });
                                  },
                                ),
                                items: state.benefitsGroupEntity.benefits
                                    .map((item) {
                                  return BenefitRedeemCardWidgetParent(
                                    spaceDetailEntity: widget.spaceDetailEntity,
                                    nftBenefitEntity: item,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(height: 436),
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
                              isButtonEnabled: true,
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
                                    latitude: locationState.latitude,
                                    longitude: locationState.longitude,
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
}
