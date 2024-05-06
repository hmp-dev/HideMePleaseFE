import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_token_entity.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/not_selected_radio.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/selected_radio.dart';

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
      decoration: BoxDecoration(
        border: !nftTokenEntity.selected
            ? null
            : Border.all(
                color: white,
                width: 1,
              ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              nftTokenEntity.imageUrl != ""
                  ? CachedNetworkImage(
                      imageUrl: nftTokenEntity.imageUrl,
                      width: 120,
                      height: 160,
                    )
                  : DefaultImage(
                      path: "assets/images/home_card_img.png",
                      width: 120,
                      height: 160,
                      boxFit: BoxFit.cover,
                    ),
              const VerticalSpace(10),
              SizedBox(
                width: 120,
                child: Text(
                  nftTokenEntity.name,
                  overflow: TextOverflow.ellipsis,
                  style: fontM(12),
                ),
              )
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: () {
                getIt<NftCubit>().onSelectDeselectNftToken(
                    selectTokenToggleRequestDto: SelectTokenToggleRequestDto(
                  nftId: nftTokenEntity.id,
                  selected: !nftTokenEntity.selected,
                  order: tokenOrder,
                ));
              },
              child: nftTokenEntity.selected
                  ? const SelectedRadio()
                  : const NotSelectedRadio(),
            ),
          ),
        ],
      ),
    );
  }
}
