import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/svg_aware_image_widget.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/not_selected_radio.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/selected_radio.dart';
import 'package:mobile/features/nft/domain/entities/nft_token_entity.dart';
import 'package:mobile/features/nft/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';

class NftTokenWidget extends StatelessWidget {
  const NftTokenWidget({
    super.key,
    required this.nftTokenEntity,
    required this.tokenAddress,
    required this.chain,
    required this.walletAddress,
    required this.tokenOrder,
  });

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
        onTap: () {
          getIt<NftCubit>().onSelectDeselectNftToken(
            requestDto: SelectTokenToggleRequestDto(
              nftId: nftTokenEntity.id,
              selected: !nftTokenEntity.selected,
              order: tokenOrder,
            ),
            selectedNft: nftTokenEntity,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Column(
                children: [
                  nftTokenEntity.imageUrl != ""
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
                          child: nftTokenEntity.imageUrl == ""
                              ? CustomImageView(
                                  imagePath:
                                      "assets/images/place_holder_card.png",
                                  width: 120,
                                  height: 160,
                                  radius: BorderRadius.circular(2),
                                  fit: BoxFit.cover,
                                )
                              : SvgAwareImageWidget(
                                  imageUrl: nftTokenEntity.imageUrl,
                                  imageWidth: 120,
                                  imageHeight: 136,
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
                            path: "assets/images/home_card_img.png",
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
