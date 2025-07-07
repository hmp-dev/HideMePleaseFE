// ignore_for_file: unused_field

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mobile/app/core/animations/animated_slide_fadein.dart';
import 'package:mobile/app/core/animations/fade_indexed_widget.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
//import 'package:mobile/features/community/presentation/cubit/community_details_cubit.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_list_widget.dart';
import 'package:mobile/features/home/presentation/widgets/chatting_widget.dart';
import 'package:mobile/features/home/presentation/widgets/events_widget.dart';
import 'package:mobile/features/home/presentation/widgets/free_welcome_nft_card.dart';
import 'package:mobile/features/home/presentation/widgets/go_to_membership_card_widget.dart';
import 'package:mobile/features/home/presentation/widgets/home_header_widget.dart';
import 'package:mobile/features/home/presentation/widgets/icon_nav_widgets.dart';
//import 'package:mobile/features/home/presentation/widgets/members_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_iconnav_row.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';

/// A [StatefulWidget] that represents the home view after a wallet is connected.
///
/// This widget is responsible for displaying the home view after a wallet is
/// connected. It takes two parameters:
///
/// - [isOverIconNavVisible]: A boolean value that determines if the icon
/// navigation is visible.
/// - [homeViewScrollController]: A [ScrollController] that controls the
/// scrolling behavior of the home view.
class HomeViewAfterWalletConnected extends StatefulWidget {
  /// Creates a [HomeViewAfterWalletConnected] widget.
  ///
  /// The [isOverIconNavVisible] parameter determines if the icon navigation is
  /// visible, and the [homeViewScrollController] parameter is a
  /// [ScrollController] that controls the scrolling behavior of the home view.
  const HomeViewAfterWalletConnected({
    super.key,
    required this.isOverIconNavVisible,
    required this.homeViewScrollController,
  });

  /// Determines if the icon navigation is visible.
  ///
  /// This value is used to determine the visibility of the icon navigation
  /// widget.
  final bool isOverIconNavVisible;

  /// A [ScrollController] that controls the scrolling behavior of the home view.
  ///
  /// This controller is used to control the scrolling behavior of the home view.
  /// It can be used to scroll to a specific position or get the current scroll
  /// offset.
  final ScrollController homeViewScrollController;

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
  final bool _isCurrentIndexIsLat = false;

  //final CarouselController _carouselController = CarouselController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeViewAfterWalletConnected oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listener: (context, nftState) {},
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

                Log.info("selectedNftsListForHome: $selectedNftsListForHome");

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    HomeHeaderWidget(connectedWallet: connectedWallet),
                    //if (kDebugMode) const TempTestButton(),
                    const SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 486,
                              viewportFraction: 0.85,
                              aspectRatio: 16 / 9,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.15,
                              autoPlayInterval: const Duration(seconds: 3),
                              onPageChanged: (int index, _) {
                                setState(() {
                                  _currentIndex = index;
                                  _currentTokenAddress =
                                      selectedNftsListForHome[index]
                                          .tokenAddress;
                                });

                                // if current index is less than last call to fetch NFT benefit
                                if (_currentIndex <
                                    selectedNftsListForHome.length - 1) {
                                  if (_currentTokenAddress != "") {
                                    getIt<NftBenefitsCubit>().onGetNftBenefits(
                                        tokenAddress: _currentTokenAddress);
                                  }
                                }
                                // if current _currentSelectWidgetIndex is fetch NFT members
                                if (_currentSelectWidgetIndex == 2) {
                                  /*getIt<CommunityDetailsCubit>()
                                      .onGetNftMembers(
                                          tokenAddress: _currentTokenAddress);*/
                                }
                              },
                            ),
                            items: selectedNftsListForHome
                                .mapIndexed((itemIndex, item) {
                              // If itemIndex is last, then return GoToMemberShipCardWidget
                              // else  return  NFTCardWidgetParent
                              if (itemIndex ==
                                  selectedNftsListForHome.length - 1) {
                                //return const GoToMemberShipCardWidget();
                                //250623 마지막 카드 비활성화
                              }

                              if (itemIndex == 0 &&
                                  nftState
                                      .welcomeNftEntity
                                      .freeNftAvailable) {
                                final welcome = nftState.welcomeNftEntity;
                                "nftState.welcomeNftEntity $welcome".log();
                                if (welcome.type == 'special') {
                                  return FreeWelcomeNftCard(
                                    welcomeNftEntity: welcome,
                                    onTapClaimButton: () {},
                                  );
                                } else if (welcome.type == 'global') {
                                  final hasSpecial = selectedNftsListForHome
                                      .any((nft) => nft.type == 'special');
                                  if (!hasSpecial) {
                                    return FreeWelcomeNftCard(
                                      welcomeNftEntity: welcome,
                                      onTapClaimButton: () {},
                                    );
                                  }
                                }else{
                                  return FreeWelcomeNftCard(
                                    welcomeNftEntity: nftState.welcomeNftEntity,
                                    onTapClaimButton: () {},
                                  );
                                }
                              }

                              return NFTCardWidgetParent(
                                imagePath: item.imageUrl,
                                videoUrl: item.videoUrl,
                                topWidget: widget.isOverIconNavVisible
                                    ? NftCardTopTitleWidget(
                                        title: item.name,
                                        chain: item.chain,
                                      )
                                    : const SizedBox.shrink(),
                                bottomWidget: _getBottomWidget(
                                    nftState.welcomeNftEntity,
                                    widget.isOverIconNavVisible,
                                    item),
                                index: itemIndex,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Text(
                    //     "selectedNftsListForHome.length:${selectedNftsListForHome.length}"),

                    // not show this for first (if free NFT not claimed )
                    // and and not show for the last index
                    if (shouldShowWidget(
                        nftState.welcomeNftEntity.freeNftAvailable,
                        _currentIndex,
                        selectedNftsListForHome))
                      GestureDetector(
                        onTap: () {
                          widget.homeViewScrollController.animateTo(
                            150,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: CustomImageView(
                          svgPath: "assets/icons/ic_angle_arrow_down.svg",
                        ),
                      ),
                    (shouldShowWidget(
                                nftState.welcomeNftEntity.freeNftAvailable,
                                _currentIndex,
                                selectedNftsListForHome) &&
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
                                      /*getIt<CommunityDetailsCubit>()
                                          .onGetNftMembers(
                                              tokenAddress:
                                                  _currentTokenAddress);*/
                                    }
                                    setState(() {
                                      _currentSelectWidgetIndex = index;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, top: 10, right: 20, bottom: 0),
                                  child: SizedBox(
                                    child: FadeIndexedWidget(
                                      index: _currentSelectWidgetIndex,
                                      children: const [
                                        BenefitListWidget(),
                                        EventsWidget(),
                                        //MemberWidget(),
                                        //ChattingWidget(),
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

  bool hasKlipProvider(List<ConnectedWalletEntity> connectedWallets) {
    bool result = false;
    if (connectedWallets.isEmpty) {
      result = false;
    }
    for (var wallet in connectedWallets) {
      if (wallet.provider == 'KLIP') {
        result = true;
      }
    }
    return result;
  }

  bool shouldShowWidget(bool isFreeNftAvailable, int currentIndex,
      List<SelectedNFTEntity> selectedNftsListForHome) {
    // Do not show for the first index if isFreeNftAvailable is false

    if (!isFreeNftAvailable == false && currentIndex == 0) {
      return false;
    }

    // Do not show for the last index
    if (currentIndex == selectedNftsListForHome.length - 1) {
      return false;
    }
    return true;
  }

  Widget _getBottomWidget(WelcomeNftEntity welcomeNftEntity,
      bool isOverIconNavVisible, SelectedNFTEntity item) {
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
                  //getIt<CommunityDetailsCubit>()
                  //    .onGetNftMembers(tokenAddress: _currentTokenAddress);
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
