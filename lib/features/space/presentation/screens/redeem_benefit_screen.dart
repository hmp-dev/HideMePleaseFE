import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_card_widget_parent.dart';
import 'package:mobile/features/home/presentation/widgets/nfc_read_process_widget.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  final _pageController = PageController(initialPage: 0);
  final CarouselController _carouselController = CarouselController();
  @override
  void initState() {
    super.initState();
    fetchBenefits();
  }

  fetchBenefits() {
    // get Benefits
    getIt<NftCubit>().onGetNftBenefits(
        tokenAddress: widget.selectedNftTokenAddress,
        spaceId: widget.nearBySpaceEntity.id);
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
                if (state.isSuccess)
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
                              onPageChanged: (int index,
                                  CarouselPageChangedReason reason) {
                                _pageController.animateToPage(index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
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
                SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: state.nftBenefitList.length,
                  effect: const WormEffect(
                    activeDotColor: hmpBlue,
                    dotColor: fore4,
                    dotHeight: 7.0,
                    dotWidth: 7.0,
                    spacing: 10.0,
                  ), // your preferred effect
                  onDotClicked: (index) {},
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, top: 50, bottom: 20),
                  child: HMPCustomButton(
                    text: LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
                    onPressed: () {
                      _showTopDialog(context);
                    },
                  ),
                )
              ],
            )),
          ),
        );
      },
    );
  }

  void _showTopDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          //insetPadding: EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
          child: Align(
            alignment: Alignment.center,
            child: NfcReadProcessWidget(
              spaceId: widget.nearBySpaceEntity.id,
              benefitId: "95f7bcab-3141-44df-b406-d50c75decd18",
              tokenAddress: widget.selectedNftTokenAddress,
            ),
          ),
        );
      },
    );
  }
}
