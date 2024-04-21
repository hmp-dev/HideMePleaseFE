import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/button_small.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';

class HomeViewAfterLoginWithOutNFT extends StatefulWidget {
  const HomeViewAfterLoginWithOutNFT({
    super.key,
  });

  @override
  State<HomeViewAfterLoginWithOutNFT> createState() =>
      _HomeViewAfterLoginWithOutNFTState();
}

class _HomeViewAfterLoginWithOutNFTState
    extends State<HomeViewAfterLoginWithOutNFT> {
  //int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        // DefaultImage(
        //   path: "assets/images/hide-me-please-logo.png",
        //   width: 200,
        // ),
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
                          "0x5aAEB6053F3E94C9b9A09f33669435E7Ef1BeAed"),
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
              onPageChanged: (int index, CarouselPageChangedReason reason) {
                setState(() {
                  // _currentIndex = index;
                });
              }),
          items: [1, 2, 3, 4, 5].map((int item) {
            return const NFTCardWidgetParent(
              imagePath: "assets/images/home_card_img.png",
              topWidget: NftCardTopWidget(),
              bottomWidget: NftCardBottomWidget(),
            );
          }).toList(),
        ),
      ],
    );
  }
}
