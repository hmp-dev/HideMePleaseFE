import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_rewards_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';

class FreeWelcomeNftCard extends StatelessWidget {
  const FreeWelcomeNftCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      builder: (context, nftState) {
        return BlocBuilder<WalletsCubit, WalletsState>(
          bloc: getIt<WalletsCubit>(),
          builder: (context, walletsState) {
            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: NFTCardWidgetParent(
                    imagePath: nftState.welcomeNftEntity.image,
                    topWidget: NftCardTopTitleWidget(
                      title: nftState.welcomeNftEntity.name,
                      chain: "KLAYTN",
                    ),
                    bottomWidget: NftCardRewardsBottomWidget(
                      welcomeNftEntity: nftState.welcomeNftEntity,
                    ),
                    index: 0,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CustomImageView(
                    imagePath: "assets/images/free-graphic-text.png",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
