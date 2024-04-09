import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/rounder_button_small.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';

class HomeViewBeforeLogin extends StatelessWidget {
  const HomeViewBeforeLogin({
    super.key,
  });

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
          onTap: () {
            getIt<HomeCubit>()
                .onUpdateHomeViewType(HomeViewType.AfterLoginWithOutNFT);
          },
        ),
        const SizedBox(height: 50),
        NFTCardWidgetParent(
          imagePath: "assets/images/home_card_img.png",
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultImage(
                  path: "assets/icons/chainIcon_x2.svg",
                  width: 40,
                  height: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  "Ready To Hide",
                  style: fontB(32),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
