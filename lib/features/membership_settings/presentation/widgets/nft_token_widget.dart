import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_token_entity.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class NftTokenWidget extends StatelessWidget {
  const NftTokenWidget({
    super.key,
    required this.nftTokenEntity,
    required this.tokenAddress,
    required this.chain,
    required this.walletAddress,
  });

  final NftTokenEntity nftTokenEntity;
  final String tokenAddress;
  final String chain;
  final String walletAddress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            CachedNetworkImage(
              imageUrl: nftTokenEntity.imageUrl,
              width: 100,
              height: 100,
            ),
            const VerticalSpace(10),
            SizedBox(
              width: 100,
              child: Text(
                nftTokenEntity.name,
                overflow: TextOverflow.ellipsis,
                style: fontM(12),
              ),
            )
          ],
        ),
        CustomRadioButton(
          value: nftTokenEntity.selected ? 1 : 0,
          groupValue: nftTokenEntity.selected ? 1 : 0,
          onChanged: (int val) {
            getIt<NftCubit>().onSelectDeselectNftToken(
                selectTokenToggleRequestDto: SelectTokenToggleRequestDto(
              tokenId: nftTokenEntity.tokenId,
              tokenAddress: tokenAddress,
              chain: chain,
              walletAddress: walletAddress,
              selected: val == 1 ? true : false,
              order: 0,
            ));
          },
        )
      ],
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final int value;
  final int groupValue;
  final Function(int) onChanged;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          color: groupValue == value ? Colors.blue : Colors.transparent,
        ),
      ),
    );
  }
}
