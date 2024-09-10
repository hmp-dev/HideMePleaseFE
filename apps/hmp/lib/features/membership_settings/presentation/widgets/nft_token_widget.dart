import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/nft_video_player.dart';
import 'package:mobile/features/common/presentation/widgets/nft_video_thumbnail.dart';
import 'package:mobile/features/common/presentation/widgets/svg_aware_image_widget.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/not_selected_radio.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/selected_radio.dart';
import 'package:mobile/features/nft/domain/entities/nft_token_entity.dart';

class NftTokenWidget extends StatelessWidget {
  const NftTokenWidget({
    super.key,
    required this.onTap,
    required this.nftTokenEntity,
    required this.tokenAddress,
    required this.chain,
    required this.walletAddress,
    required this.tokenOrder,
  });

  final VoidCallback onTap;
  final NftTokenEntity nftTokenEntity;
  final String tokenAddress;
  final String chain;
  final String walletAddress;
  final int tokenOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Column(
                children: [
                  nftTokenEntity.videoUrl != ""
                      ? NftVideoThumbnailFromUrl(
                          imageWidth: 120,
                          imgHeight: 160,
                          videoUrl: nftTokenEntity.videoUrl,
                        )
                      : nftTokenEntity.imageUrl != ""
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: !nftTokenEntity.selected
                                    ? null
                                    : Border.all(
                                        color: white,
                                        width: 2,
                                      ),
                              ),
                              child: SvgAwareImageWidget(
                                imageUrl: nftTokenEntity.imageUrl,
                                imageWidth: 120,
                                imageHeight: 160,
                                imageBorderRadius: 2,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: !nftTokenEntity.selected
                                    ? null
                                    : Border.all(
                                        color: white,
                                        width: 2,
                                      ),
                              ),
                              child: DefaultImage(
                                path: "assets/images/place_holder_card.png",
                                width: 120,
                                height: 160,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                ],
              ),
              Positioned(
                bottom: 40,
                left: 10,
                child: SizedBox(
                  width: 120,
                  child: Text(
                    nftTokenEntity.name,
                    overflow: TextOverflow.ellipsis,
                    style: fontCompactSm(),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: nftTokenEntity.selected
                    ? const SelectedRadio()
                    : const NotSelectedRadio(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
