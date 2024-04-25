import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/button_small.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
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
                      Container(
                        height: 54,
                        width: 54,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: cececeColor,
                        ),
                      ),
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
                      DefaultImage(
                        path: "assets/icons/ic_notification.svg",
                        width: 32,
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
                    return NFTCardWidgetParent(
                      imagePath: item.nftImageUrl ?? "",
                      topWidget: const NftCardTopWidget(),
                      bottomWidget: const NftCardBottomWidget(),
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
