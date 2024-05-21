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
import 'package:mobile/features/common/presentation/widgets/page_dot_indicator.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_card_widget_parent.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/presentation/views/nfc_read_process_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

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
                  child: HMPCustomButton(
                    text: LocaleKeys.redeemYourBenefitsBtnTitle.tr(),
                    onPressed: () {
                      NfcReadProcessView.push(
                        context: context,
                        spaceId: widget.nearBySpaceEntity.id,
                        benefitId: selectedBenefitId != ""
                            ? selectedBenefitId
                            : state.nftBenefitList[0].id,
                        tokenAddress: widget.selectedNftTokenAddress,
                      );
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
}
