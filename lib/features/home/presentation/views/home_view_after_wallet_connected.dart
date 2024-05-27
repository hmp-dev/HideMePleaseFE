// ignore_for_file: unused_field

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/animations/animated_slide_fadein.dart';
import 'package:mobile/app/core/animations/fade_indexed_stack.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefits_widget.dart';
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
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';

class HomeViewAfterWalletConnected extends StatefulWidget {
  const HomeViewAfterWalletConnected({
    super.key,
    required this.isOverIconNavVisible,
  });

  final bool isOverIconNavVisible;

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
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listener: (context, nftState) {},
      builder: (context, nftState) {
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            BlocConsumer<WalletsCubit, WalletsState>(
              bloc: getIt<WalletsCubit>(),
              listener: (context, walletsState) {},
              builder: (context, walletsState) {
                final connectedWallet = walletsState.connectedWallets;
                List<SelectedNFTEntity> selectedNftsListForHome =
                    nftState.nftsListHome;

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
                              viewportFraction: 0.8,
                              aspectRatio: 16 / 9,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.12,
                              autoPlayInterval: const Duration(seconds: 3),
                              onPageChanged: (int index,
                                  CarouselPageChangedReason reason) {
                                setState(() {
                                  _currentIndex = index;
                                  _currentTokenAddress =
                                      selectedNftsListForHome[index]
                                          .tokenAddress;
                                });

                                // if index is last item,
                                // and set _isCurrentIndexIsLat as true
                                if (_currentIndex ==
                                    selectedNftsListForHome.length - 1) {
                                  setState(() => _isCurrentIndexIsLat = true);
                                } else {
                                  // else set isItemFirstOrLast as false
                                  setState(() => _isCurrentIndexIsLat = false);
                                  //call NFt Benefits API
                                  getIt<NftCubit>().onGetNftBenefits(
                                      tokenAddress:
                                          selectedNftsListForHome[index]
                                              .tokenAddress
                                              .trim());
                                }
                              },
                            ),
                            items: selectedNftsListForHome.map((item) {
                              final itemIndex =
                                  selectedNftsListForHome.indexOf(item);

                              // If itemIndex is last, then return GoToMemberShipCardWidget
                              // else  return  NFTCardWidgetParent
                              if (itemIndex ==
                                  selectedNftsListForHome.length - 1) {
                                return const GoToMemberShipCardWidget();
                              }
                              return GestureDetector(
                                onTap: () {
                                  final locationState =
                                      getIt<EnableLocationCubit>().state;

                                  if (locationState.latitude == 0.0 ||
                                      locationState.longitude == 0.0) {
                                    getIt<EnableLocationCubit>()
                                        .onAskDeviceLocation();
                                  } else {
                                    getIt<SpaceCubit>().onGetSpacesData(
                                      tokenAddress: item.tokenAddress,
                                      latitude: 2.0, //locationState.latitude,
                                      longitude: 2.0,
                                    ); //locationState.longitude);
                                  }

                                  Log.trace(
                                      "latitude: ${locationState.latitude}");
                                  Log.trace(
                                      "longitude: ${locationState.longitude}");
                                },
                                child: NFTCardWidgetParent(
                                  imagePath: itemIndex == 0
                                      ? nftState.welcomeNftEntity.image
                                      : item.imageUrl,
                                  topWidget: NftCardTopTitleWidget(
                                    title: item.name,
                                    chain: item.chain,
                                  ),
                                  bottomWidget: _getBottomWidget(
                                      itemIndex,
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
                          child: _getBadgeWidget(_currentIndex),
                        ),
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
                                    setState(() {
                                      _currentSelectWidgetIndex = index;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, top: 10, right: 20, bottom: 50),
                                  child: FadeIndexedStack(
                                    index: _currentSelectWidgetIndex,
                                    children: const [
                                      BenefitsWidget(),
                                      EventsWidget(),
                                      MemberWidget(),
                                      ChattingWidget(),
                                    ],
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

  Widget _getBadgeWidget(int itemIndex) {
    if (itemIndex == 0) {
      return CustomImageView(
        imagePath: "assets/images/free-graphic-text.png",
      );
    } else if (itemIndex == 1) {
      return CustomImageView(
        svgPath: "assets/images/nfc-illustration.svg",
        height: 100,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _getBottomWidget(int itemIndex, WelcomeNftEntity welcomeNftEntity,
      bool isOverIconNavVisible, SelectedNFTEntity item) {
    if (itemIndex == 0) {
      return NftCardRewardsBottomWidget(welcomeNftEntity: welcomeNftEntity);
    } else {
      return isOverIconNavVisible
          ? const AnimatedSlideFadeIn(
              slideIndex: 0,
              beginOffset: Offset(0.0, 0.01),
              child: NftCardIconNavRow(),
            )
          : AnimatedSlideFadeIn(
              slideIndex: 0,
              beginOffset: const Offset(0.0, 0.01),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
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
