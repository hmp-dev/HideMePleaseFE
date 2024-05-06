import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/button_small.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/go_to_membership_card_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_widget.dart';
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
            return Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Container(
                      DefaultImage(
                        path: "assets/images/metamask_wallet_icon.svg",
                        height: 54,
                      ),
                      const HorizontalSpace(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatWalletAddress(
                                  connectedWallet[0].publicAddress),
                              textAlign: TextAlign.center,
                              style: fontSB(18, lineHeight: 1.4),
                            ),
                            const VerticalSpace(10),
                            ButtonSmall(
                              title: "연결된 지갑 1개",
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          // getIt<HomeCubit>().onUpdateHomeViewType(
                          //     HomeViewType.beforeWalletConnected);

                          // getIt<ProfileCubit>().onUpdateUserProfile(
                          //     UpdateProfileRequestDto(nickName: "Dave John"));

                          // getIt<NftCubit>().onGetWelcomeNft();

                          //getIt<NftCubit>().onGetUserSelectedNfts();

                          getIt<NftCubit>()
                              .onGetConsumeWelcomeNft(welcomeNftId: 2);
                        },
                        child: DefaultImage(
                          path: "assets/icons/ic_notification.svg",
                          width: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                      height: 486,
                      viewportFraction: 0.8,
                      aspectRatio: 16 / 9,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.12,
                      autoPlayInterval: const Duration(seconds: 3),
                      onPageChanged:
                          (int index, CarouselPageChangedReason reason) {
                        setState(() {
                          // _currentIndex = index;
                        });
                      }),
                  items: nftState.selectedNftTokensList.map((item) {
                    final itemIndex =
                        nftState.selectedNftTokensList.indexOf(item);
                    // If itemIndex is last, then return GoToMemberShipCardWidget
                    // else  return  NFTCardWidgetParent
                    if (itemIndex ==
                        nftState.selectedNftTokensList.length - 1) {
                      return const GoToMemberShipCardWidget();
                    }
                    return NFTCardWidgetParent(
                      imagePath: item.imageUrl,
                      topWidget: const NftCardTopWidget(),
                      bottomWidget: const NftCardBottomWidget(),
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
}
