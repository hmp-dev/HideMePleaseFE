import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_rewards_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';

/// A widget that displays a welcome NFT card.
///
/// This widget is used to display a welcome NFT card with its image, name, and rewards.
/// It also includes an optional free graphic overlay.
class FreeWelcomeNftCard extends StatelessWidget {
  /// Creates a [FreeWelcomeNftCard].
  ///
  /// The [enableFreeGraphic] parameter determines whether the free graphic overlay should be shown.
  /// The [welcomeNftEntity] parameter is the entity containing the details of the welcome NFT.
  const FreeWelcomeNftCard({
    super.key,
    this.enableFreeGraphic = true,
    required this.welcomeNftEntity,
  });

  /// Determines whether the free graphic overlay should be shown.
  final bool enableFreeGraphic;

  /// The entity containing the details of the welcome NFT.
  final WelcomeNftEntity welcomeNftEntity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container for the NFT card widget parent
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
        // Optional free graphic overlay
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
