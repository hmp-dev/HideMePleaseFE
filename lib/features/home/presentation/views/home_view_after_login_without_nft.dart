import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/rounder_button_small.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        DefaultImage(
          path: "assets/images/hide-me-please-logo.png",
          width: 200,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "지갑을 연결하고\n웹컴 NFT를 받아보세요!",
            textAlign: TextAlign.center,
            style: fontR(18, lineHeight: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        RoundedButtonSmall(
          title: "지갑연결하기",
          onTap: () {},
        ),
        const SizedBox(height: 50),
        const NFTCardWidgetParent(
          imagePath: "assets/images/home_card_img.png",
          topWidget: NftCardTopWidget(),
          bottomWidget: NftCardTopWidget(),
          index: 0,
        )
      ],
    );
  }
}
