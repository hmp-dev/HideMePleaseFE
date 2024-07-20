import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_rewards_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';

class FreeWelcomeNftCard extends StatelessWidget {
  const FreeWelcomeNftCard({
    super.key,
    this.enableFreeGraphic = true,
    required this.welcomeNftEntity,
  });

  final bool enableFreeGraphic;
  final WelcomeNftEntity welcomeNftEntity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: NFTCardWidgetParent(
            imagePath: welcomeNftEntity.image,
            topWidget: NftCardTopTitleWidget(
              title: welcomeNftEntity.name,
              chain: "KLAYTN",
            ),
            bottomWidget: NftCardRewardsBottomWidget(
              welcomeNftEntity: welcomeNftEntity,
            ),
            index: 0,
          ),
        ),
        if (enableFreeGraphic)
          Positioned(
            right: 0,
            top: 0,
            child: CustomImageView(
              imagePath: "assets/images/free-graphic-text.png",
            ),
          ),
      ],
    );
  }
}
