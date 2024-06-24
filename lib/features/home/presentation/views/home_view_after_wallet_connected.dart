// ignore_for_file: unused_field

import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/animations/animated_slide_fadein.dart';
import 'package:mobile/app/core/animations/fade_indexed_widget.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/community/presentation/cubit/community_details_cubit.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_list_widget.dart';
import 'package:mobile/features/home/presentation/widgets/chatting_widget.dart';
import 'package:mobile/features/home/presentation/widgets/events_widget.dart';
import 'package:mobile/features/home/presentation/widgets/go_to_membership_card_widget.dart';
import 'package:mobile/features/home/presentation/widgets/home_header_widget.dart';
import 'package:mobile/features/home/presentation/widgets/icon_nav_widgets.dart';
import 'package:mobile/features/home/presentation/widgets/members_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_iconnav_row.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_rewards_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/space/presentation/screens/benefit_redeem_initiate_widget.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';

class HomeViewAfterWalletConnected extends StatefulWidget {
  const HomeViewAfterWalletConnected({
    super.key,
    required this.isOverIconNavVisible,
    required this.homeViewScrollController,
    required this.userProfile,
  });

  final bool isOverIconNavVisible;
  final ScrollController homeViewScrollController;
  final UserProfileEntity userProfile;

  @override
  State<HomeViewAfterWalletConnected> createState() =>
      _HomeViewAfterWalletConnectedState();
}

class _HomeViewAfterWalletConnectedState
    extends State<HomeViewAfterWalletConnected>
    with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  int _currentSelectWidgetIndex = 0;
  String _currentTokenAddress = "";
  bool _isCurrentIndexIsLat = false;

  final CarouselController _carouselController = CarouselController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeViewAfterWalletConnected oldWidget) {
    super.didUpdateWidget(oldWidget);

    "HomeViewAfterWalletConnected: ${widget.isOverIconNavVisible}".log();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    "HomeViewAfterWalletConnected: didChangeDependencies".log();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      builder: (context, nftState) {
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            BlocBuilder<WalletsCubit, WalletsState>(
              bloc: getIt<WalletsCubit>(),
              builder: (context, walletsState) {
                final connectedWallet = walletsState.connectedWallets;
                List<SelectedNFTEntity> selectedNftsListForHome =
                    nftState.nftsListHome;
                final bool isCurrentNftFreeNft =
                    _currentIndex == 0 && !widget.userProfile.freeNftClaimed;

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    HomeHeaderWidget(connectedWallet: connectedWallet),
                    const SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: 486,
                              viewportFraction: 0.85,
                              aspectRatio: 16 / 9,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.15,
                              autoPlayInterval: const Duration(seconds: 3),
                              onPageChanged: (int index,
                                  CarouselPageChangedReason reason) {
                                setState(() {
                                  _currentIndex = index;
                                  _currentTokenAddress =
                                      selectedNftsListForHome[index]
                                          .tokenAddress;
                                });

                                "the Current TokenAddress is $_currentTokenAddress"
                                    .log();

                                // if index is last item,
                                // and set _isCurrentIndexIsLat as true
                                if (_currentIndex ==
                                    selectedNftsListForHome.length - 1) {
                                  setState(() => _isCurrentIndexIsLat = true);
                                } else {
                                  // else set isItemFirstOrLast as false
                                  setState(() => _isCurrentIndexIsLat = false);

                                  //call NFt Benefits API
                                  if (_currentIndex > 0) {
                                    getIt<NftBenefitsCubit>().onGetNftBenefits(
                                        tokenAddress: _currentTokenAddress);
                                  }

                                  if (_currentSelectWidgetIndex == 2) {
                                    getIt<CommunityDetailsCubit>()
                                        .onGetNftMembers(
                                            tokenAddress: _currentTokenAddress);
                                  }
                                }
                              },
                            ),
                            items: selectedNftsListForHome
                                .mapIndexed((itemIndex, item) {
                              final bool showFreeNftClaim = itemIndex == 0 &&
                                  !widget.userProfile.freeNftClaimed;

                              // If itemIndex is last, then return GoToMemberShipCardWidget
                              // else  return  NFTCardWidgetParent
                              if (itemIndex ==
                                  selectedNftsListForHome.length - 1) {
                                return const GoToMemberShipCardWidget();
                              }
                              return BenefitRedeemInitiateWidget(
                                tokenAddress: _currentTokenAddress,
                                onAlertCancel: () {
                                  Navigator.pop(context);
                                },
                                childWidget: NFTCardWidgetParent(
                                  imagePath: showFreeNftClaim
                                      ? nftState.welcomeNftEntity.image
                                      : item.imageUrl,
                                  topWidget: widget.isOverIconNavVisible
                                      ? NftCardTopTitleWidget(
                                          title: item.name,
                                          chain: item.chain,
                                        )
                                      : const SizedBox.shrink(),
                                  bottomWidget: _getBottomWidget(
                                      showFreeNftClaim,
                                      nftState.welcomeNftEntity,
                                      widget.isOverIconNavVisible,
                                      item),
                                  index: itemIndex,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Positioned(
                            top: 0,
                            right: 30,
                            child: _getBadgeWidget(
                                isCurrentNftFreeNft,
                                _currentIndex,
                                selectedNftsListForHome.isEmpty,
                                selectedNftsListForHome.length - 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // not show this for first and last index
                    if (_currentIndex != 0 &&
                        _currentIndex != selectedNftsListForHome.length - 1)
                      CustomImageView(
                        svgPath: "assets/icons/ic_angle_arrow_down.svg",
                      ),
                    (!_isCurrentIndexIsLat &&
                            _currentIndex != 0 &&
                            !widget.isOverIconNavVisible)
                        ? AnimatedSlideFadeIn(
                            slideIndex: 0,
                            beginOffset: const Offset(0.0, 0.5),
                            child: Column(
                              children: [
                                IconNavWidgets(
                                  selectedIndex: _currentSelectWidgetIndex,
                                  onIndexChanged: (index) {
                                    if (index == 2) {
                                      getIt<CommunityDetailsCubit>()
                                          .onGetNftMembers(
                                              tokenAddress:
                                                  _currentTokenAddress);
                                    }
                                    setState(() {
                                      _currentSelectWidgetIndex = index;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, top: 10, right: 20, bottom: 30),
                                  child: SizedBox(
                                    child: FadeIndexedWidget(
                                      index: _currentSelectWidgetIndex,
                                      children: const [
                                        BenefitListWidget(),
                                        EventsWidget(),
                                        MemberWidget(),
                                        ChattingWidget(),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : const VerticalSpace(400),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getBadgeWidget(bool showFreeNftClaim, int itemIndex,
      bool isSelectedNftsListEmpty, int itemsLength) {
    if (showFreeNftClaim) {
      return CustomImageView(
        imagePath: "assets/images/free-graphic-text.png",
      );
    } else if (itemIndex > 0 && itemIndex < itemsLength) {
      return !isSelectedNftsListEmpty
          ? const SizedBox.shrink()
          // CustomImageView(
          //     svgPath: "assets/images/nfc-illustration.svg",
          //     height: 100,
          //   )
          : const SizedBox.shrink();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _getBottomWidget(
      bool showFreeNftClaim,
      WelcomeNftEntity welcomeNftEntity,
      bool isOverIconNavVisible,
      SelectedNFTEntity item) {
    if (showFreeNftClaim) {
      return NftCardRewardsBottomWidget(welcomeNftEntity: welcomeNftEntity);
    } else {
      return isOverIconNavVisible
          ? AnimatedSlideFadeIn(
              slideIndex: 0,
              beginOffset: const Offset(0.0, 0.01),
              child: NftCardIconNavRow(
                selectedIndex: _currentSelectWidgetIndex,
                onIndexChanged: (index) {
                  widget.homeViewScrollController.animateTo(
                    120,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  if (index == 2) {
                    getIt<CommunityDetailsCubit>()
                        .onGetNftMembers(tokenAddress: _currentTokenAddress);
                  }
                  setState(() {
                    _currentSelectWidgetIndex = index;
                  });
                },
              ),
            )
          : AnimatedSlideFadeIn(
              slideIndex: 0,
              beginOffset: const Offset(0.0, 0.01),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: bg1,
                          shape: BoxShape.circle,
                        ),
                        child: CustomImageView(
                          svgPath: "assets/icons/ic_angle_arrow_down.svg",
                        ),
                      ),
                    ),
                    NftCardTopTitleWidget(
                      title: item.name,
                      chain: item.chain,
                    ),
                  ],
                ),
              ),
            );
    }
  }
}
