// ignore_for_file: unused_field

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/common/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/home/presentation/widgets/go_to_membership_card_widget.dart';
import 'package:mobile/features/home/presentation/widgets/home_header_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_rewards_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_iconnav_row.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';

class HomeViewAfterWalletConnected extends StatefulWidget {
  const HomeViewAfterWalletConnected({
    super.key,
  });

  @override
  State<HomeViewAfterWalletConnected> createState() =>
      _HomeViewAfterWalletConnectedState();
}

class _HomeViewAfterWalletConnectedState
    extends State<HomeViewAfterWalletConnected> {
  int _currentIndex = 0;
  String _currentTokenAddress = "";

  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listener: (context, nftState) {},
      builder: (context, nftState) {
        return BlocConsumer<WalletsCubit, WalletsState>(
          bloc: getIt<WalletsCubit>(),
          listener: (context, walletsState) {},
          builder: (context, walletsState) {
            final connectedWallet = walletsState.connectedWallets;
            List<SelectedNFTEntity> selectedNfts = nftState.nftsListHome;

            return Column(
              children: [
                const SizedBox(height: 20),
                HomeHeaderWidget(connectedWallet: connectedWallet),
                const SizedBox(height: 20),
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 510,
                    viewportFraction: 0.8,
                    aspectRatio: 16 / 9,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.12,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged:
                        (int index, CarouselPageChangedReason reason) {
                      setState(() {
                        _currentIndex = index;
                        _currentTokenAddress = selectedNfts[index].tokenAddress;
                      });

                      //call NFt Benefits API
                      getIt<NftCubit>().onGetNftBenefits(
                          tokenAddress:
                              selectedNfts[index].tokenAddress.trim());
                    },
                  ),
                  items: selectedNfts.map((item) {
                    final itemIndex = selectedNfts.indexOf(item);
                    // If itemIndex is last, then return GoToMemberShipCardWidget
                    // else  return  NFTCardWidgetParent
                    if (itemIndex == selectedNfts.length - 1) {
                      return const GoToMemberShipCardWidget();
                    }
                    return NFTCardWidgetParent(
                      imagePath: itemIndex == 0
                          ? nftState.welcomeNftEntity.image
                          : item.imageUrl,
                      topWidget: NftCardTopTitleWidget(
                        title: item.name,
                        chain: item.chain,
                      ),
                      bottomWidget: _getBottomWidget(
                          itemIndex, nftState.welcomeNftEntity),
                      badgeWidget: _getBadgeWidget(itemIndex),
                      index: itemIndex,
                    );
                  }).toList(),
                ),
              ],
            );
          },
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

  Widget _getBottomWidget(int itemIndex, WelcomeNftEntity welcomeNftEntity) {
    if (itemIndex == 0) {
      return NftCardRewardsBottomWidget(welcomeNftEntity: welcomeNftEntity);
    } else {
      return const NftCardIconNavRow();
    }
  }
}
